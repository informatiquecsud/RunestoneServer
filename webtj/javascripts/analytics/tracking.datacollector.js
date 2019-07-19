window.trackingIfParameterPopulated = function(value) {
    if (value != '') {
        return value;
    }
    else {
        return undefined;
    }
}

window.trackingTrackClassEvent = function(ev) {
    var target = ev.target || ev.srcElement;

    if (target.tagName === 'A') {
    	if (target.classList && target.classList.contains('track')) {

    		var data = JSON.parse("{}");
    		if (target.getAttribute('data-track') != null) {
		        data = JSON.parse(target.getAttribute('data-track'));
		    }
		    ORA.click({
		        "data": {
		            "ev_cat": data.ev_cat || 'click',
		            "ev_label": data.ev_label ||
		                        (target.getAttribute('title') || '').replace(/^\s+|\s+$/gm, '') ||
		                        (target.getAttribute('alt') || '').replace(/^\s+|\s+$/gm, '') ||
		                        (target.innerText || '').replace(/^\s+|\s+$/gm, '') ||
		                        (target.find('img').getAttribute('title') || '').replace(/^\s+|\s+$/gm, '') ||
		                        (target.find('img').getAttribute('alt') || '').replace(/^\s+|\s+$/gm, ''),

		            "ev_target": data.ev_target || target.getAttribute('href'),
		            "WT.dl": "99"
		        }
		    });
    	}
    }
}

window.trackingTrackDownloadEvent = function(ev) {
    var target = ev.target || ev.srcElement;

    if (target.nodeName === 'A') {
        href = target.getAttribute('href');

        if (href.match(/\.(xls|doc|pdf|txt|csv|zip|docx|xlsx)\??\#?/)) {
            var aLink = document.createElement('a');
            aLink.href = href;
            ORA.click({
                "data": {
                    "wt.ti": 'Download:http://' + aLink.hostname + aLink.pathname,
                    "dcsuri": aLink.pathname,
                    "WT.dl": "20"
                }
            });
        }
    }
}

window.trackingTrackEvent = function(data) {
    data['wt.dl'] = data['wt.dl'] || '99';
    ORA.click({
        "data": data
    });
}

if (DataLayer.events) {
	//listen for link click events at the document level
	if (document.addEventListener) {
	    document.addEventListener('click', trackingTrackClassEvent,false);
	} else if (document.attachEvent) {
	    document.attachEvent('onclick', trackingTrackClassEvent,false);
	}
}
if (document.addEventListener) {
    document.addEventListener('click', trackingTrackDownloadEvent,false);
} else if (document.attachEvent) {
    document.attachEvent('onclick', trackingTrackDownloadEvent,false);
}

(function() {
    var s = document.createElement("script");
    s.async = true;
    s.src = "https://c.oracleinfinity.io/acs/account/qavjwd2etc/js/main/odc.js";
    var s2 = document.getElementsByTagName("script")[0];
    
    s.onload = function() {
        var DL = DataLayer;
        //ORA.analyticsModule.prototype.oraConfigObj.s_disableSeed = false;
        ORA.analyticsModule.prototype.oraConfigObj.FPCConfig = {
            domain: DL.wt_fpc_domain || ".ethz.ch",
            enabled: true
        };
        old_postload = ORA.analyticsModule.prototype.postload;
        ORA.analyticsModule.prototype.postload = function() {
            //ORA.analytics.dcsRef.FPCConfig.domain = DL.wt_fpc_domain || ".ethz.ch";
            ORA.analytics.addMutation("defaults", function(msg) {
                if (DL.page_lang === '')                                            DL.page_lang = $('html').attr('lang');
                if (DL.oss_term === '')                                             DL.oss_term = $('input#form-searchfield-searchinputMain').attr('value');
                if (typeof DL.oss_term == 'string' && DL.oss_term != '')            DL.oss_results = ($('div.searchResultList div.nav-hint').first().text().split(/\s/i).pop() || '0');
                if (typeof DL.oss_engine == 'undefined' || DL.oss_engine == '')     DL.oss_engine = 'ethz';
                if (DL.site === '')                                                 DL.site = window.location.hostname;
 
                if (typeof DL.oss_term == 'undefined' || DL.oss_term == '') {
                    DL.oss_term = undefined;
                    DL.oss_results = undefined;
                    DL.oss_engine = undefined;
                }

                msg.setParam("dcsipa",          "1");
                msg.setParam("wt.i_native",     "1");

                msg.setParam("WT.sp",           trackingIfParameterPopulated(DL.site));
                msg.setParam("iuri",            trackingIfParameterPopulated(DL.uri_internal));
                msg.setParam("lang",            trackingIfParameterPopulated(DL.page_lang));
                msg.setParam("WT.cg_n",         trackingIfParameterPopulated(DL.page_group));
                msg.setParam("WT.cg_s",         trackingIfParameterPopulated(DL.page_subgroup));
                msg.setParam("ext",             trackingIfParameterPopulated(DL.visit_ext));

                if (msg.getParam('wt.dl') == 0) {
                    msg.setParam("WT.oss",          trackingIfParameterPopulated(DL.oss_term));
                    msg.setParam("WT.oss_r",        trackingIfParameterPopulated(DL.oss_results));
                    msg.setParam("WT.oss_e",        trackingIfParameterPopulated(DL.oss_engine));
                }

                try{
                    var canonical = document.head.querySelector("[property='og:url'][content]").content;
                    if (canonical) {
                        var aCanonical = document.createElement('a');
                        aCanonical.href = canonical;
                        msg.setParam("WT.es",   trackingIfParameterPopulated(aCanonical.hostname + aCanonical.pathname), true);
                        msg.setParam("dcssip",  trackingIfParameterPopulated(aCanonical.hostname), true);
                        msg.setParam("dcsuri",  trackingIfParameterPopulated(aCanonical.pathname), true);       
                    }
                    var canonical = document.head.querySelector("[property='og:title'][content]").content;
                    if (canonical) {
                        msg.setParam("WT.ti",   trackingIfParameterPopulated(canonical), true);  
                    }
                }
                catch(e){};

            });
            old_postload();
            ORA.view();
        }

    }
    
    s2.parentNode.insertBefore(s, s2);
}());

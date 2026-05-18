function landingNormalizeLocale(raw) {
  if (!raw || typeof raw !== "string") return "fr";
  var c = raw.trim().toLowerCase();
  if (c.startsWith("en")) return "en";
  if (c.startsWith("de")) return "de";
  if (c.startsWith("es")) return "es";
  if (c.startsWith("pt")) return "pt";
  if (c.startsWith("ko")) return "ko";
  if (c.startsWith("fr")) return "fr";
  return "fr";
}

function htmlLangFromCode(code) {
  var m = { fr: "fr", en: "en", de: "de", es: "es", pt: "pt", ko: "ko" };
  var n = landingNormalizeLocale(code);
  return m[n] ? m[n] : "fr";
}

window.landingDetectInitialLocale = function landingDetectInitialLocale() {
  try {
    var s = typeof sessionStorage !== "undefined" ? sessionStorage.getItem("paychek_landing_lang") : null;
    if (s) return landingNormalizeLocale(s);
  } catch (_e0) {}
  return landingNormalizeLocale(typeof navigator !== "undefined" && navigator.language ? navigator.language : "fr");
};

window.landingSaveLocale = function landingSaveLocale(code) {
  var n = landingNormalizeLocale(code || "fr");
  try {
    if (typeof sessionStorage !== "undefined") sessionStorage.setItem("paychek_landing_lang", n);
  } catch (_e1) {}
  return n;
};

function getAtPath(root, dotted) {
  if (!root || dotted == null) return undefined;
  var parts = String(dotted).split(".").filter(Boolean);
  var cur = root;
  for (var i = 0; i < parts.length; i++) {
    cur = cur[parts[i]];
    if (cur === undefined || cur === null) return undefined;
  }
  return cur;
}

window.buildPreviewData = function buildPreviewData(code) { var lc = landingNormalizeLocale(code); var t = window.PAYCHEK_LANDING_I18N[lc]; if (!t) return {}; var m = window.PAYCHEK_LANDING_MEDIA || {}; var out = {}; Object.keys(m).forEach(function (key) { var bm = m[key] || {}; var mod = (t.previewModules && t.previewModules[key]) || {}; var b = {}; if (bm.imgs && bm.imgs.length) b.imgs = bm.imgs.slice(); if (bm.img) b.img = bm.img; if (mod.imgAlts && mod.imgAlts.length) b.imgAlts = mod.imgAlts.slice(); else if (mod.imgAlt) b.imgAlt = mod.imgAlt; if (mod.title != null) b.title = mod.title; if (mod.lead != null) b.lead = mod.lead; if (mod.desc != null) b.desc = mod.desc; if (mod.descPoints) b.descPoints = mod.descPoints; out[key] = b; }); return out; };

function mergePreviewGlobally(merged) { try { if (typeof previewData !== "undefined" && previewData != null && typeof previewData === "object") { Object.keys(merged || {}).forEach(function (key) { previewData[key] = Object.assign({}, previewData[key] || {}, merged[key]); }); window.previewData = previewData; return; } } catch (_eM) {} window.previewData = merged; }

function setPricingLiText(liEl, labelText) {
  if (!liEl) return;
  var icon = liEl.querySelector("i.fas");
  Array.prototype.slice.call(liEl.childNodes).forEach(function (n) {
    if (n !== icon) liEl.removeChild(n);
  });
  var holder = document.createElement("span");
  holder.setAttribute("data-paychek-li-text", "1");
  holder.textContent = String(labelText || "").trim();
  if (icon) icon.insertAdjacentElement("afterend", holder);
  else liEl.appendChild(holder);
}

function applyFAQ(s) { if (!s || !s.faq || !s.faq.items) return; var flagged = Array.prototype.slice.call(document.querySelectorAll("[data-faq-index]")); flagged.forEach(function (node, idxFb) { var idxRaw = node.getAttribute("data-faq-index"); var j = typeof idxRaw === "string" && idxRaw.length ? parseInt(idxRaw, 10) : idxFb; var it = typeof j === "number" && s.faq.items[j] ? s.faq.items[j] : null; if (!it) return; var trig = node.querySelector("[data-faq-trigger]") || node.querySelector(".faq-trigger span"); var cnt = node.querySelector("[data-faq-content]") || node.querySelector(".faq-content"); if (!trig) { var ft = node.querySelector(".faq-trigger"); trig = ft && ft.children.length ? ft.children[0] : null; } if (trig) trig.textContent = it.q || ""; if (cnt && it.aHtml != null) cnt.innerHTML = it.aHtml; }); if (flagged.length) return; Array.prototype.slice.call(document.querySelectorAll(".faq-item")).forEach(function (el, idx) { var item = s.faq.items[idx]; if (!item) return; var tr = el.querySelector(".faq-trigger span"); var cw = el.querySelector(".faq-content"); if (tr) tr.textContent = item.q || ""; if (cw && item.aHtml != null) cw.innerHTML = item.aHtml; }); }

function applyPricingFeatures(strings) { if (!strings || !strings.pricing) return; document.querySelectorAll("[data-paychek-pricing=\"lite\"] li,#pricing-lite-features li").forEach(function (li, ix) { var path = li.getAttribute("data-i18n"); var lx = li.getAttribute("data-pricing-lite-index"); if (lx != null) ix = parseInt(lx, 10); var lbl = path ? getAtPath(strings, path) : null; if (lbl == null && strings.pricing.featuresLite && strings.pricing.featuresLite[ix] != null) lbl = strings.pricing.featuresLite[ix]; if (lbl != null) setPricingLiText(li, lbl); }); document.querySelectorAll("[data-paychek-pricing=\"pro\"] li,#pricing-pro-features li").forEach(function (li, ix) { var path = li.getAttribute("data-i18n"); var lx = li.getAttribute("data-pricing-pro-index"); if (lx != null) ix = parseInt(lx, 10); var lbl = path ? getAtPath(strings, path) : null; if (lbl == null && strings.pricing.featuresPro && strings.pricing.featuresPro[ix] != null) lbl = strings.pricing.featuresPro[ix]; if (lbl != null) setPricingLiText(li, lbl); }); if (document.querySelector("[data-paychek-pricing=lite],[data-paychek-pricing=pro],#pricing-lite-features,#pricing-pro-features")) return; var cards = Array.prototype.slice.call(document.querySelectorAll("#pricing .pricing-card")); if (cards.length < 2) return; var liteRows = cards[0].querySelectorAll("ul li"); var proRows = cards[1].querySelectorAll("ul li"); var fl = strings.pricing.featuresLite; var fp = strings.pricing.featuresPro; var i; if (fl) { for (i = 0; i < liteRows.length && i < fl.length; i++) { if (liteRows[i].querySelector("i")) setPricingLiText(liteRows[i], fl[i]); } } if (fp) { for (i = 0; i < proRows.length && i < fp.length; i++) { if (proRows[i].querySelector("i")) setPricingLiText(proRows[i], fp[i]); } } }

function bindDataAttrs(s){ if(!s) return; Array.prototype.slice.call(document.querySelectorAll("[data-i18n]")).forEach(function(el){var p=el.getAttribute("data-i18n"); if(!p) return; if(el.closest&&el.closest("#pricing"))return; var v=getAtPath(s,p); if(typeof v==="string") el.textContent=v; }); Array.prototype.slice.call(document.querySelectorAll("[data-i18n-html]")).forEach(function(el){var p=el.getAttribute("data-i18n-html");var v=getAtPath(s,p); if(typeof v==="string") el.innerHTML=v; }); Array.prototype.slice.call(document.querySelectorAll("[data-i18n-aria]")).forEach(function(el){var p=el.getAttribute("data-i18n-aria");var v=getAtPath(s,p); if(typeof v==="string") el.setAttribute("aria-label",v); }); Array.prototype.slice.call(document.querySelectorAll("[data-i18n-title]")).forEach(function(el){var p=el.getAttribute("data-i18n-title");var v=getAtPath(s,p); if(typeof v==="string") el.setAttribute("title",v); }); }

function refreshExplorerTabs(s){ if(!s||!s.tabs) return; Object.keys(s.tabs).forEach(function(k){ var tb=document.getElementById("tab-"+k); var lab=s.tabs[k]; if(tb!=null&&lab!=null) tb.textContent=lab; }); }

function refreshNav(s) {
  if (!s || !s.nav) return;
  var row = document.querySelector("nav div.hidden.lg\\:flex");
  if (row) {
    var links = row.querySelectorAll("a");
    var keys = ["preview", "process", "pricing", "faq"];
    for (var i = 0; i < keys.length && i < links.length; i++) {
      var k = keys[i];
      if (s.nav[k] != null) links[i].textContent = s.nav[k];
    }
  }
  var loginBtn =
    document.querySelector("nav [data-paychek-auth='login']") ||
    document.querySelector("nav button[onclick*='login']");
  var signupBtn =
    document.querySelector("nav [data-paychek-auth='signup']") ||
    document.querySelector("nav button[onclick*='signup']");
  if (loginBtn && s.nav.login != null) loginBtn.textContent = s.nav.login;
  if (signupBtn && s.nav.signup != null) {
    while (signupBtn.firstChild) signupBtn.removeChild(signupBtn.firstChild);
    signupBtn.textContent = s.nav.signup;
  }
}

function refreshHero(s) {
  if (!s || !s.hero) return;
  var wrap =
    document.querySelector("header [data-paychek-store-nav]") ||
    document.querySelector("header div.flex.flex-wrap[role='navigation']");
  if (wrap && s.hero.storeNavAria) wrap.setAttribute("aria-label", s.hero.storeNavAria);
  var gp = document.querySelector(".paychek-store-badge-google");
  if (gp && s.hero.googlePlayAria) gp.setAttribute("aria-label", s.hero.googlePlayAria);
  var ap = document.querySelector(".paychek-store-badge-appstore");
  if (ap && s.hero.appStoreAria) ap.setAttribute("aria-label", s.hero.appStoreAria);
  Array.prototype.slice
    .call(document.querySelectorAll("[data-i18n-html='hero.titleHtml']"))
    .forEach(function (el) {
      if (s.hero.titleHtml != null) el.innerHTML = s.hero.titleHtml;
    });
  if (!document.querySelector("[data-i18n-html='hero.titleHtml']")) {
    var h1 =
      document.querySelector("header h1.paychek-hero-title") ||
      document.querySelector("header h1");
    if (h1 && s.hero.titleHtml != null) h1.innerHTML = s.hero.titleHtml;
  }
  Array.prototype.slice
    .call(document.querySelectorAll("[data-i18n-html='hero.taglineHtml']"))
    .forEach(function (el) {
      if (s.hero.taglineHtml != null) el.innerHTML = s.hero.taglineHtml;
    });
  if (!document.querySelector("[data-i18n-html='hero.taglineHtml']")) {
    var tg = document.querySelector("header .paychek-hero-tagline");
    if (tg && s.hero.taglineHtml != null) tg.innerHTML = s.hero.taglineHtml;
  }
  Array.prototype.slice
    .call(document.querySelectorAll("[data-i18n='hero.ctaStart']"))
    .forEach(function (b) {
      if (s.hero.ctaStart != null) b.textContent = s.hero.ctaStart;
    });
  Array.prototype.slice
    .call(document.querySelectorAll("[data-i18n='hero.ctaExplore']"))
    .forEach(function (b) {
      if (s.hero.ctaExplore != null) b.textContent = s.hero.ctaExplore;
    });
  var row = document.querySelector("header div.flex.flex-col.sm\\:flex-row");
  if (!row) row = document.querySelector("header div.flex.flex-col");
  if (row) {
    var bn = row.querySelectorAll(".btn-primary,.btn-secondary");
    if (
      bn.length >= 1 &&
      !document.querySelector("[data-i18n='hero.ctaStart']") &&
      s.hero.ctaStart != null
    )
      bn[0].textContent = s.hero.ctaStart;
    if (
      bn.length >= 2 &&
      !document.querySelector("[data-i18n='hero.ctaExplore']") &&
      s.hero.ctaExplore != null
    )
      bn[1].textContent = s.hero.ctaExplore;
  }
}

function applyPreviewChrome(p){ if(!p)return; var im=document.getElementById("preview-img"); if(im){ if(p.lightboxExpand!=null) im.setAttribute("title",p.lightboxExpand); if(p.previewImgAria!=null) im.setAttribute("aria-label",p.previewImgAria);} var lb=document.getElementById("preview-lightbox"); if(lb&&p.dialogAria!=null) lb.setAttribute("aria-label",p.dialogAria); var cbtn=document.querySelector("#preview-lightbox .relative.flex.shrink-0 button"); if(cbtn&&p.lightboxClose!=null) cbtn.setAttribute("aria-label",p.lightboxClose); var cc=document.getElementById("preview-carousel-controls"); if(cc){ var btns=cc.querySelectorAll("button"); if(btns[0]&&p.prevImg!=null){ btns[0].setAttribute("title",p.prevImg); btns[0].setAttribute("aria-label",p.prevImg); } if(btns[1]&&p.nextImg!=null){ btns[1].setAttribute("title",p.nextImg); btns[1].setAttribute("aria-label",p.nextImg);} } }

function applyProcess(proc) {
  if (!proc || !proc.steps) return;
  var root = document.getElementById("processus");
  if (!root) return;
  var hh = root.querySelector("h3");
  if (hh && proc.title != null) hh.textContent = proc.title;
  var cards = root.querySelectorAll(".step-card");
  var steps = proc.steps || [];
  for (var i = 0; i < cards.length && i < steps.length; i++) {
    var st = steps[i];
    var imx = cards[i].querySelector(".step-image-wrapper img");
    var h =
      cards[i].querySelector("[data-process-step-title]") ||
      cards[i].querySelector("h5");
    var p =
      cards[i].querySelector("[data-process-desc]") ||
      cards[i].querySelector(".p-8.pt-0.text-center p") ||
      cards[i].querySelector("p.text-gray-500");
    if (imx && st.imgAlt != null) imx.alt = st.imgAlt;
    if (h && st.title != null) h.textContent = st.title;
    if (p && st.desc != null) p.textContent = st.desc;
  }
} 

function applyPricingTexts(s) {
  if (!s || !s.pricing) return;
  var p = s.pricing;
  var pc = document.getElementById("pricing");
  if (!pc) return;
  var compare = document.getElementById("pricing-compare");
  if (!compare) return;

  var head = pc.querySelector("[data-pricing-head]");
  if (head) {
    var title = head.querySelector("[data-pricing-title]");
    if (title && p.titleHtml != null) title.innerHTML = p.titleHtml;
    var sub = head.querySelector("[data-pricing-subtitle]");
    if (sub && p.subtitle != null) sub.textContent = p.subtitle;
  }

  var periodMap = { "1m": p.period1m, "3m": p.period3m, "1y": p.period1y };
  Object.keys(periodMap).forEach(function (code) {
    var btn = document.getElementById("btn-pricing-" + code);
    var lbl = btn && btn.querySelector("[data-pricing-period-label]");
    if (lbl && periodMap[code] != null) lbl.textContent = periodMap[code];
  });
  var b22 = pc.querySelector("[data-pricing-badge-22]");
  if (b22 && p.badgeSave22 != null) b22.textContent = p.badgeSave22;
  var b44 = pc.querySelector("[data-pricing-badge-44]");
  if (b44 && p.badgeSave44 != null) b44.textContent = p.badgeSave44;

  function setText(sel, val) {
    if (val == null) return;
    var el = compare.querySelector(sel);
    if (el) el.textContent = val;
  }
  setText("[data-pricing-lite-standard]", p.liteStandard);
  setText("[data-pricing-lite-label]", p.liteLabel);
  setText("[data-pricing-lite-free]", p.liteFree);
  setText("[data-pricing-lite-basic]", p.liteFeaturesBasic);
  setText("[data-pricing-pro-unlimited]", p.proUnlimited);
  setText("[data-pricing-pro-label]", p.proLabel);
  setText("[data-pricing-pro-badge]", p.proBadge);
  setText("[data-pricing-cta-current]", p.ctaCurrent);

  var rowSpecs = [
    { id: "trades", row: "rowTrades", lite: "liteTrades", pro: "proTrades" },
    { id: "entry", row: "rowEntry", lite: "liteEntry", pro: "proEntry" },
    { id: "calendar", row: "rowCalendar", lite: "liteCalendar", pro: "proCalendar" },
    { id: "checklist", row: "rowChecklist", lite: "liteAbsent", pro: "proChecklist" },
    { id: "analysis", row: "rowAnalysis", lite: "liteAbsent", pro: "proAnalysis" },
    { id: "strategy", row: "rowStrategy", lite: "liteAbsent", pro: "proStrategy" },
    { id: "performance", row: "rowPerformance", lite: "liteAbsent", pro: "proPerformance" },
    { id: "psychology", row: "rowPsychology", lite: "liteAbsent", pro: "proPsychology" },
    { id: "reports", row: "rowReports", lite: "liteAbsent", pro: "proReports" },
  ];
  rowSpecs.forEach(function (spec) {
    var row = compare.querySelector('[data-pricing-row="' + spec.id + '"]');
    if (!row) return;
    var liteLbl = row.querySelector("[data-pricing-lite-label-row]");
    var proLbl = row.querySelector("[data-pricing-pro-label-row]");
    var liteVal = row.querySelector("[data-pricing-lite-value]");
    var proVal = row.querySelector("[data-pricing-pro-value]");
    if (liteLbl && p[spec.row] != null) liteLbl.textContent = p[spec.row];
    if (proLbl && p[spec.row] != null) proLbl.textContent = p[spec.row];
    if (liteVal && p[spec.lite] != null) liteVal.textContent = p[spec.lite];
    if (proVal && p[spec.pro] != null) proVal.textContent = p[spec.pro];
  });

  var trialMain = pc.querySelector("[data-pricing-trial-main]");
  var trialSub = pc.querySelector("[data-pricing-trial-sub]");
  if (trialMain && p.trialMain != null) trialMain.textContent = p.trialMain;
  if (trialSub && p.trialSub != null) trialSub.textContent = p.trialSub;

  window.PAYCHEK_LANDING_PRICING_PERIODS = p.periods || {};
  if (typeof window.paychekSelectPricingPeriod === "function") {
    window.paychekSelectPricingPeriod(window.paychekPricingPeriod || "1y");
  }
} 

function applyFooter(f){ if(!f)return;var slog=document.querySelector("footer > div.max-w-7xl > div > div.flex.flex-col.gap-6 > p"); if(!slog) slog=document.querySelector("footer > div.max-w-7xl > div p.text-gray-500"); if(!slog) slog=document.querySelector("footer p.text-\[10px\].font-bold.uppercase"); if(slog&&f.slogan!=null) slog.textContent=f.slogan;var hn=document.querySelectorAll("footer ul.flex.flex-col.gap-4"); var tn=document.querySelectorAll("footer h6.uppercase"); if(tn.length>=4){ if(f.columnProduct!=null) tn[0].textContent=f.columnProduct; if(f.columnCompany!=null) tn[1].textContent=f.columnCompany;if(f.columnResources!=null) tn[2].textContent=f.columnResources;if(f.columnLegal!=null) tn[3].textContent=f.columnLegal;} if(hn.length>=4){ var a=hn[0].querySelectorAll("a"); var o=[f.feat,f.pricing,f.faq,f.updates];for(var i=0;i<4;i++) if(a[i]&&o[i]!=null) a[i].textContent=o[i]; a=hn[1].querySelectorAll("a"); o=[f.about,f.careers,f.affiliate,f.contact];for(i=0;i<4;i++) if(a[i]&&o[i]!=null) a[i].textContent=o[i]; a=hn[2].querySelectorAll("a"); o=[f.blog,f.guideTrading,f.webinars,f.documentation];for(i=0;i<4;i++) if(a[i]&&o[i]!=null) a[i].textContent=o[i]; a=hn[3].querySelectorAll("a"); o=[f.privacy,f.terms,f.security,f.cookies];for(i=0;i<4;i++) if(a[i]&&o[i]!=null) a[i].textContent=o[i]; } var crs=document.querySelectorAll("footer > div.flex.flex-col > div.mt-32 p"); if(crs.length<2) crs=document.querySelectorAll("footer .border-white\/5 p"); if(crs[0]&&f.copyright!=null) crs[0].textContent=f.copyright;if(crs[1]&&f.designedFor!=null) crs[1].textContent=f.designedFor;} 

function applyModals(m){ if(!m)return;var lh=document.querySelector("#login-modal h2"); var sh=document.querySelector("#signup-modal h2"); if(lh&&m.loginTitle!=null) lh.textContent=m.loginTitle; if(sh&&m.signupTitle!=null) sh.textContent=m.signupTitle;var sn=document.querySelector("#signup-modal p.text-\[9px\]"); if(sn&&m.trialNoteHtml!=null) sn.innerHTML=m.trialNoteHtml; var lin=document.querySelectorAll("#login-modal input"); if(lin[0]&&m.emailPh!=null) lin[0].placeholder=m.emailPh; if(lin[1]&&m.passwordPh!=null) lin[1].placeholder=m.passwordPh;var sin=document.querySelectorAll("#signup-modal input"); if(sin[0]&&m.fullNamePh!=null) sin[0].placeholder=m.fullNamePh; if(sin[1]&&m.emailPh!=null) sin[1].placeholder=m.emailPh; if(sin[2]&&m.passwordPh!=null) sin[2].placeholder=m.passwordPh; var lb=document.querySelector("#login-modal .btn-primary"); var sb=document.querySelector("#signup-modal .btn-primary"); if(lb&&m.loginSubmit!=null) lb.textContent=m.loginSubmit; if(sb&&m.signupSubmit!=null) sb.textContent=m.signupSubmit;} 

function manualPreviewFill(key,merged){ var d=(merged&&merged[key])||null; var tt=document.getElementById("preview-title"); var ld=document.getElementById("preview-lead"); if(tt&&d&&d.title!=null) tt.textContent=d.title; if(ld&&d){ if(d.lead){ ld.textContent=d.lead; ld.classList.remove("hidden");} else { ld.textContent=""; ld.classList.add("hidden");} } if(typeof setPreviewDesc==="function"&&d) setPreviewDesc(d);}

function refreshCarouselAltFromMerged(key,merged){ var im=document.getElementById("preview-img"); if(!im|| !merged||!merged[key]) return; var d=merged[key]; if(d.imgAlts&&d.imgAlts.length){ var ck=typeof previewCarouselKey!=="undefined"?previewCarouselKey:null; var ix=(typeof previewCarouselIndex!=="undefined"?previewCarouselIndex:0)||0;if(ck===key&&d.imgAlts[ix]!=null){ im.alt=d.imgAlts[ix];}else if(!ck&&d.imgAlt!=null){ im.alt=d.imgAlt;} } else if(d.imgAlt!=null) im.alt=d.imgAlt;}

function refreshPreviewAfter(code,merged,s){ refreshExplorerTabs(s); mergePreviewGlobally(merged); var btn=document.querySelector(".explorer-tab.active"); var key=btn&&btn.id&&btn.id.indexOf("tab-")===0?btn.id.slice(4):"dashboard"; if(typeof switchPreview==="function"){try{switchPreview(key);}catch(_sw){manualPreviewFill(key,merged); refreshCarouselAltFromMerged(key,merged);} } else {manualPreviewFill(key,merged); refreshCarouselAltFromMerged(key,merged);} } 

window.applyLandingTranslations = function (code) {
  var lc = landingNormalizeLocale(code);
  var s = (window.PAYCHEK_LANDING_I18N || {})[lc];
  if (!s) return lc;
  document.documentElement.setAttribute("lang", htmlLangFromCode(lc));
  if (s.meta && s.meta.title) document.title = s.meta.title;
  try {
    bindDataAttrs(s);
  } catch (_b) {}
  try {
    refreshNav(s);
  } catch (_n) {}
  try {
    refreshHero(s);
  } catch (_h) {}
  try {
    if (s.preview) applyPreviewChrome(s.preview);
  } catch (_p) {}
  try {
    if (s.process) applyProcess(s.process);
  } catch (_pr) {}
  try {
    applyPricingTexts(s);
  } catch (_pt) {}
  try {
    applyPricingFeatures(s);
  } catch (_pf) {}
  try {
    applyFAQ(s);
  } catch (_f) {}
  try {
    applyFooter(s.footer || {});
  } catch (_ft) {}
  try {
    applyModals(s.modals || {});
  } catch (_m) {}
  var merged = window.buildPreviewData(lc);
  mergePreviewGlobally(merged);
  try {
    refreshPreviewAfter(lc, merged, s);
  } catch (_r) {}
  return lc;
}; 
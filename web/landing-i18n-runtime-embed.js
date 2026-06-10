function landingNormalizeLocale(raw) {
  if (!raw || typeof raw !== "string") return "en";
  var c = raw.trim().toLowerCase();
  if (c.startsWith("en")) return "en";
  if (c.startsWith("de")) return "de";
  if (c.startsWith("es")) return "es";
  if (c.startsWith("pt")) return "pt";
  if (c.startsWith("ko")) return "ko";
  if (c.startsWith("fr")) return "fr";
  return "en";
}

function htmlLangFromCode(code) {
  var m = { fr: "fr", en: "en", de: "de", es: "es", pt: "pt", ko: "ko" };
  var n = landingNormalizeLocale(code);
  return m[n] ? m[n] : "en";
}

window.landingDetectInitialLocale = function landingDetectInitialLocale() {
  try {
    var s = typeof sessionStorage !== "undefined" ? sessionStorage.getItem("paychek_landing_lang") : null;
    if (s) return landingNormalizeLocale(s);
  } catch (_e0) {}
  return landingNormalizeLocale(typeof navigator !== "undefined" && navigator.language ? navigator.language : "en");
};

window.landingSaveLocale = function landingSaveLocale(code) {
  var n = landingNormalizeLocale(code || "en");
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

var _paychekPricingStrings = null;
var _paychekPricingSelected = "1y";
var _paychekPricingPlansBound = false;

var _paychekPricingRowSpecs = [
  ["trades", "rowTrades", "liteTrades", "proTrades"],
  ["entry", "rowEntry", "liteEntry", "proEntry"],
  ["calendar", "rowCalendar", "liteCalendar", "proCalendar"],
  ["checklist", "rowChecklist", "liteAbsent", "proChecklist"],
  ["analysis", "rowAnalysis", "liteAbsent", "proAnalysis"],
  ["strategy", "rowStrategy", "liteAbsent", "proStrategy"],
  ["performance", "rowPerformance", "liteAbsent", "proPerformance"],
  ["psychology", "rowPsychology", "liteAbsent", "proPsychology"],
  ["reports", "rowReports", "liteAbsent", "proReports"]
];

function paychekSelectPricingPlan(period) {
  _paychekPricingSelected = period;
  document.querySelectorAll(".paychek-plan-card").forEach(function (card) {
    var active = card.getAttribute("data-pricing-period") === period;
    card.classList.toggle("paychek-plan-selected", active);
    card.setAttribute("aria-checked", active ? "true" : "false");
  });
  paychekUpdatePricingMainCta();
}

function paychekUpdatePricingMainCta() {
  var btn = document.getElementById("paychek-pricing-main-cta");
  var p = _paychekPricingStrings && _paychekPricingStrings.pricing;
  if (!btn || !p || !p.periods) return;
  var period = p.periods[_paychekPricingSelected];
  if (period && period.cta != null) btn.textContent = period.cta;
}

function initPaychekPricingPlans() {
  if (_paychekPricingPlansBound) return;
  var root = document.getElementById("paychek-pricing-plans");
  if (!root) return;
  _paychekPricingPlansBound = true;
  root.querySelectorAll(".paychek-plan-card").forEach(function (card) {
    card.addEventListener("click", function () {
      paychekSelectPricingPlan(card.getAttribute("data-pricing-period"));
    });
  });
}

function applyPricingPlans(p) {
  if (!p || !p.periods) return;
  var titleKeys = { "1y": "period1y", "3m": "period3m", "1m": "period1m" };
  var badgeKeys = { "1y": "badgeSave44", "3m": "badgeSave22", "1m": null };
  Object.keys(titleKeys).forEach(function (key) {
    var card = document.querySelector('.paychek-plan-card[data-pricing-period="' + key + '"]');
    var period = p.periods[key];
    if (!card || !period) return;
    var titleEl = card.querySelector('[data-pricing-field="title"]');
    var savingEl = card.querySelector('[data-pricing-field="saving"]');
    var priceEl = card.querySelector('[data-pricing-field="price"]');
    var labelEl = card.querySelector('[data-pricing-field="label"]');
    var badgeEl = card.querySelector("[data-pricing-badge]");
    if (titleEl && p[titleKeys[key]] != null) titleEl.textContent = p[titleKeys[key]];
    if (savingEl && period.saving != null) savingEl.textContent = period.saving;
    if (priceEl && period.price != null) priceEl.textContent = period.price;
    if (labelEl && period.label != null) labelEl.textContent = period.label;
    if (badgeEl) {
      var badgeKey = badgeKeys[key];
      if (!badgeKey) {
        badgeEl.classList.add("is-hidden");
        badgeEl.classList.remove("is-muted");
      } else {
        badgeEl.classList.remove("is-hidden");
        badgeEl.textContent = p[badgeKey] || "";
        if (key === "1y") {
          badgeEl.classList.remove("is-muted");
        } else {
          badgeEl.classList.add("is-muted");
        }
      }
    }
  });
  paychekUpdatePricingMainCta();
}

function applyPricingCompare(p) {
  if (!p) return;
  _paychekPricingRowSpecs.forEach(function (spec) {
    var row = document.querySelector('[data-pricing-row="' + spec[0] + '"]');
    if (!row) return;
    var rowLabel = p[spec[1]] || "";
    var liteVal = p[spec[2]];
    var proVal = p[spec[3]] || "";
    row.querySelectorAll('[data-pricing-cell="label"]').forEach(function (el) {
      el.textContent = rowLabel;
    });
    var liteCell = row.querySelector('[data-pricing-cell="lite"]');
    var proCell = row.querySelector('[data-pricing-cell="pro"]');
    if (liteCell) {
      var absent = spec[2] === "liteAbsent" || liteVal === "×";
      liteCell.textContent = absent ? "×" : liteVal || "";
      liteCell.classList.toggle("is-absent", absent);
    }
    if (proCell) {
      proCell.textContent = proVal;
      proCell.classList.remove("is-absent");
    }
  });
}

function applyPricingFeatures(strings) {
  if (!document.getElementById("paychek-pricing-compare")) return;
  if (strings && strings.pricing) applyPricingCompare(strings.pricing);
}

function bindDataAttrs(s) {
  if (!s) return;
  Array.prototype.slice.call(document.querySelectorAll("[data-i18n]")).forEach(function (el) {
    var p = el.getAttribute("data-i18n");
    if (!p) return;
    if (el.closest && el.closest("#paychek-pricing-compare .paychek-compare-row")) return;
    var v = getAtPath(s, p);
    if (typeof v === "string") el.textContent = v;
  });
  Array.prototype.slice.call(document.querySelectorAll("[data-i18n-html]")).forEach(function (el) {
    var p = el.getAttribute("data-i18n-html");
    var v = getAtPath(s, p);
    if (typeof v === "string") el.innerHTML = v;
  });
  Array.prototype.slice.call(document.querySelectorAll("[data-i18n-aria]")).forEach(function (el) {
    var p = el.getAttribute("data-i18n-aria");
    var v = getAtPath(s, p);
    if (typeof v === "string") el.setAttribute("aria-label", v);
  });
  Array.prototype.slice.call(document.querySelectorAll("[data-i18n-title]")).forEach(function (el) {
    var p = el.getAttribute("data-i18n-title");
    var v = getAtPath(s, p);
    if (typeof v === "string") el.setAttribute("title", v);
  });
}

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
  _paychekPricingStrings = s;
  var pc = document.getElementById("pricing");
  if (!pc) return;
  if (document.getElementById("paychek-pricing-plans")) {
    applyPricingPlans(s.pricing);
    applyPricingCompare(s.pricing);
    initPaychekPricingPlans();
  }
  var trial = document.querySelector("#pricing .btn-trial");
  if (trial) {
    var q = trial.querySelectorAll("p");
    if (q[0] && s.pricing.trialMain != null) q[0].textContent = s.pricing.trialMain;
    if (q[1] && s.pricing.trialSub != null) q[1].textContent = s.pricing.trialSub;
  }
}

// Footer : tout le texte porte des attributs [data-i18n] (footer.*), traités par bindDataAttrs.
function applyFooter(_f){ return; }

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
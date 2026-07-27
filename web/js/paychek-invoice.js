'use strict';

/**
 * Paychek account invoice / receipt — print-ready HTML (Save as PDF).
 * Shared by licence.html and facturation.html.
 */
(function (global) {
  var I18N = {
    en: {
      invoiceTitle: 'Invoice',
      receiptTitle: 'Account statement',
      brandTagline: 'Trading journal · paychek.pro',
      invoiceNo: 'Document no.',
      date: 'Date',
      billTo: 'Bill to',
      customer: 'Customer',
      email: 'Email',
      description: 'Description',
      period: 'Period / validity',
      channel: 'Billing channel',
      amount: 'Amount',
      status: 'Status',
      planPro: 'Paychek Journal Pro',
      planLite: 'Paychek Journal Lite',
      noPeriod: 'No end date on file',
      amountUnknown: 'See Stripe / App Store / Google Play for the charged amount',
      amountFree: 'Free — no charge',
      amountNoteStore:
        'Official payment receipts are issued by your billing provider (Stripe, App Store or Google Play).',
      thanks: 'Thank you for using Paychek.',
      support: 'Support',
      supportUrl: 'https://paychek.pro/contact.html',
      site: 'https://paychek.pro',
      printHint: 'Use your browser’s print dialog → Save as PDF.',
      printBtn: 'Print / Save as PDF',
      closeBtn: 'Close',
      footerNote:
        'This document summarizes your Paychek account status. It is not a substitute for the official invoice from Stripe or the store when a payment was charged.',
      channelStripe: 'Stripe (web)',
      channelApple: 'App Store',
      channelGoogle: 'Google Play',
      channelAdmin: 'Granted by Paychek',
      channelNone: '—',
      statusPro: 'Active Pro',
      statusLite: 'Lite (free)',
    },
    fr: {
      invoiceTitle: 'Facture',
      receiptTitle: 'Reçu / relevé de compte',
      brandTagline: 'Journal de trading · paychek.pro',
      invoiceNo: 'N° document',
      date: 'Date',
      billTo: 'Facturé à',
      customer: 'Client',
      email: 'E-mail',
      description: 'Description',
      period: 'Période / validité',
      channel: 'Canal de facturation',
      amount: 'Montant',
      status: 'Statut',
      planPro: 'Paychek Journal Pro',
      planLite: 'Paychek Journal Lite',
      noPeriod: 'Pas de date de fin enregistrée',
      amountUnknown:
        'Voir Stripe / App Store / Google Play pour le montant débité',
      amountFree: 'Gratuit — aucun montant',
      amountNoteStore:
        'Les reçus de paiement officiels sont émis par votre prestataire (Stripe, App Store ou Google Play).',
      thanks: 'Merci d’utiliser Paychek.',
      support: 'Support',
      supportUrl: 'https://paychek.pro/contact.html',
      site: 'https://paychek.pro',
      printHint: 'Utilisez Imprimer du navigateur → Enregistrer au format PDF.',
      printBtn: 'Imprimer / Enregistrer en PDF',
      closeBtn: 'Fermer',
      footerNote:
        'Ce document résume le statut de votre compte Paychek. Il ne remplace pas la facture officielle Stripe ou du store lorsqu’un paiement a été débité.',
      channelStripe: 'Stripe (web)',
      channelApple: 'App Store',
      channelGoogle: 'Google Play',
      channelAdmin: 'Accordé par Paychek',
      channelNone: '—',
      statusPro: 'Pro actif',
      statusLite: 'Lite (gratuit)',
    },
    de: {
      invoiceTitle: 'Rechnung',
      receiptTitle: 'Kontoauszug',
      brandTagline: 'Trading-Journal · paychek.pro',
      invoiceNo: 'Dokumentnr.',
      date: 'Datum',
      billTo: 'Rechnungsempfänger',
      customer: 'Kunde',
      email: 'E-Mail',
      description: 'Beschreibung',
      period: 'Zeitraum / Gültigkeit',
      channel: 'Abrechnungskanal',
      amount: 'Betrag',
      status: 'Status',
      planPro: 'Paychek Journal Pro',
      planLite: 'Paychek Journal Lite',
      noPeriod: 'Kein Enddatum hinterlegt',
      amountUnknown: 'Betrag siehe Stripe / App Store / Google Play',
      amountFree: 'Kostenlos — keine Gebühr',
      amountNoteStore:
        'Offizielle Zahlungsbelege stellt Ihr Anbieter (Stripe, App Store oder Google Play) aus.',
      thanks: 'Danke, dass Sie Paychek nutzen.',
      support: 'Support',
      supportUrl: 'https://paychek.pro/contact.html',
      site: 'https://paychek.pro',
      printHint: 'Druckdialog → Als PDF speichern.',
      printBtn: 'Drucken / Als PDF speichern',
      closeBtn: 'Schließen',
      footerNote:
        'Dieses Dokument fasst Ihren Paychek-Kontostatus zusammen und ersetzt keine offizielle Stripe-/Store-Rechnung.',
      channelStripe: 'Stripe (Web)',
      channelApple: 'App Store',
      channelGoogle: 'Google Play',
      channelAdmin: 'Von Paychek freigeschaltet',
      channelNone: '—',
      statusPro: 'Pro aktiv',
      statusLite: 'Lite (kostenlos)',
    },
    es: {
      invoiceTitle: 'Factura',
      receiptTitle: 'Extracto / recibo',
      brandTagline: 'Diario de trading · paychek.pro',
      invoiceNo: 'N.º documento',
      date: 'Fecha',
      billTo: 'Facturar a',
      customer: 'Cliente',
      email: 'Correo',
      description: 'Descripción',
      period: 'Periodo / validez',
      channel: 'Canal de facturación',
      amount: 'Importe',
      status: 'Estado',
      planPro: 'Paychek Journal Pro',
      planLite: 'Paychek Journal Lite',
      noPeriod: 'Sin fecha de fin registrada',
      amountUnknown: 'Ver Stripe / App Store / Google Play para el importe',
      amountFree: 'Gratis — sin cargo',
      amountNoteStore:
        'Los recibos oficiales los emite su proveedor (Stripe, App Store o Google Play).',
      thanks: 'Gracias por usar Paychek.',
      support: 'Soporte',
      supportUrl: 'https://paychek.pro/contact.html',
      site: 'https://paychek.pro',
      printHint: 'Imprimir del navegador → Guardar como PDF.',
      printBtn: 'Imprimir / Guardar PDF',
      closeBtn: 'Cerrar',
      footerNote:
        'Este documento resume el estado de su cuenta Paychek. No sustituye la factura oficial de Stripe o la tienda.',
      channelStripe: 'Stripe (web)',
      channelApple: 'App Store',
      channelGoogle: 'Google Play',
      channelAdmin: 'Concedido por Paychek',
      channelNone: '—',
      statusPro: 'Pro activo',
      statusLite: 'Lite (gratis)',
    },
    pt: {
      invoiceTitle: 'Fatura',
      receiptTitle: 'Extrato / recibo',
      brandTagline: 'Diário de trading · paychek.pro',
      invoiceNo: 'N.º documento',
      date: 'Data',
      billTo: 'Faturar a',
      customer: 'Cliente',
      email: 'E-mail',
      description: 'Descrição',
      period: 'Período / validade',
      channel: 'Canal de faturação',
      amount: 'Montante',
      status: 'Estado',
      planPro: 'Paychek Journal Pro',
      planLite: 'Paychek Journal Lite',
      noPeriod: 'Sem data de fim registada',
      amountUnknown: 'Ver Stripe / App Store / Google Play para o montante',
      amountFree: 'Gratuito — sem cobrança',
      amountNoteStore:
        'Os recibos oficiais são emitidos pelo seu fornecedor (Stripe, App Store ou Google Play).',
      thanks: 'Obrigado por usar o Paychek.',
      support: 'Suporte',
      supportUrl: 'https://paychek.pro/contact.html',
      site: 'https://paychek.pro',
      printHint: 'Imprimir do browser → Guardar como PDF.',
      printBtn: 'Imprimir / Guardar PDF',
      closeBtn: 'Fechar',
      footerNote:
        'Este documento resume o estado da sua conta Paychek. Não substitui a fatura oficial Stripe ou da loja.',
      channelStripe: 'Stripe (web)',
      channelApple: 'App Store',
      channelGoogle: 'Google Play',
      channelAdmin: 'Concedido pela Paychek',
      channelNone: '—',
      statusPro: 'Pro ativo',
      statusLite: 'Lite (gratuito)',
    },
    ko: {
      invoiceTitle: '청구서',
      receiptTitle: '계정 명세서',
      brandTagline: '트레이딩 저널 · paychek.pro',
      invoiceNo: '문서 번호',
      date: '날짜',
      billTo: '청구 대상',
      customer: '고객',
      email: '이메일',
      description: '내용',
      period: '기간 / 유효',
      channel: '결제 경로',
      amount: '금액',
      status: '상태',
      planPro: 'Paychek Journal Pro',
      planLite: 'Paychek Journal Lite',
      noPeriod: '등록된 종료일 없음',
      amountUnknown: '금액은 Stripe / App Store / Google Play에서 확인',
      amountFree: '무료 — 요금 없음',
      amountNoteStore:
        '공식 결제 영수증은 Stripe, App Store 또는 Google Play에서 발급됩니다.',
      thanks: 'Paychek을 이용해 주셔서 감사합니다.',
      support: '지원',
      supportUrl: 'https://paychek.pro/contact.html',
      site: 'https://paychek.pro',
      printHint: '브라우저 인쇄 → PDF로 저장.',
      printBtn: '인쇄 / PDF 저장',
      closeBtn: '닫기',
      footerNote:
        '이 문서는 Paychek 계정 상태를 요약한 것이며 Stripe/스토어 공식 청구서를 대체하지 않습니다.',
      channelStripe: 'Stripe (웹)',
      channelApple: 'App Store',
      channelGoogle: 'Google Play',
      channelAdmin: 'Paychek 제공',
      channelNone: '—',
      statusPro: 'Pro 활성',
      statusLite: 'Lite (무료)',
    },
  };

  function escapeHtml(s) {
    return String(s == null ? '' : s)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;');
  }

  function normalizeLocale(code) {
    var c = String(code || 'en').toLowerCase().slice(0, 2);
    return I18N[c] ? c : 'en';
  }

  function strings(locale) {
    return I18N[normalizeLocale(locale)] || I18N.en;
  }

  function normalizeChannel(raw) {
    var api = global.paychekAccountEntitlement;
    if (api && typeof api.normalizeBillingChannel === 'function') {
      return api.normalizeBillingChannel(raw);
    }
    return String(raw || '')
      .trim()
      .toLowerCase();
  }

  function channelLabel(t, method) {
    var c = normalizeChannel(method);
    if (c === 'stripe') return t.channelStripe;
    if (c === 'apple_iap') return t.channelApple;
    if (c === 'google_play') return t.channelGoogle;
    if (c === 'admin') return t.channelAdmin;
    return t.channelNone;
  }

  function formatDate(d, locale) {
    if (!d) return null;
    try {
      return new Intl.DateTimeFormat(normalizeLocale(locale), {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
      }).format(d instanceof Date ? d : new Date(d));
    } catch (_e) {
      try {
        return (d instanceof Date ? d : new Date(d)).toISOString().slice(0, 10);
      } catch (_e2) {
        return null;
      }
    }
  }

  function docNumber(uid) {
    var now = new Date();
    var y = now.getFullYear();
    var m = String(now.getMonth() + 1).padStart(2, '0');
    var d = String(now.getDate()).padStart(2, '0');
    var seed = String(uid || 'guest').replace(/[^a-zA-Z0-9]/g, '');
    var short = (seed.slice(0, 4) + seed.slice(-4)).toUpperCase() || 'ACCT';
    if (short.length < 4) short = (short + 'XXXX').slice(0, 4);
    return 'PCK-' + y + m + d + '-' + short.slice(0, 8);
  }

  /**
   * Meaningful paid/subscription record → invoice download enabled.
   * Pro / store / Stripe / admin entitlement → true.
   * Free Lite with no billing channel → false (no free “reçu”).
   */
  function isInvoiceStyle(opts) {
    if (!opts) return false;
    if (opts.isPro) return true;
    var c = normalizeChannel(opts.paymentMethod);
    return !!(c && c !== '');
  }

  /** Alias: only paid / entitled accounts may open the document. */
  function canDownloadDocument(opts) {
    return isInvoiceStyle(opts);
  }

  function buttonLabel(locale, opts) {
    var t = strings(locale);
    return isInvoiceStyle(opts) ? t.invoiceTitle : t.receiptTitle;
  }

  function downloadButtonLabel(locale, opts) {
    var t = strings(locale);
    var base = isInvoiceStyle(opts) ? t.invoiceTitle : t.receiptTitle;
    var prefixes = {
      en: 'Download ',
      fr: 'Télécharger ',
      de: '',
      es: 'Descargar ',
      pt: 'Descarregar ',
      ko: '',
    };
    var loc = normalizeLocale(locale);
    if (loc === 'de') return base + ' herunterladen';
    if (loc === 'ko') return base + ' 다운로드';
    if (loc === 'fr') {
      return isInvoiceStyle(opts)
        ? 'Télécharger la facture'
        : 'Télécharger le reçu';
    }
    return (prefixes[loc] || 'Download ') + base.toLowerCase();
  }

  function buildHtml(opts) {
    opts = opts || {};
    var locale = normalizeLocale(opts.locale);
    var t = strings(locale);
    var invoiceLike = isInvoiceStyle(opts);
    var title = invoiceLike ? t.invoiceTitle : t.receiptTitle;
    var email = String(opts.email || '').trim() || '—';
    var name = String(opts.displayName || '').trim() || email;
    var plan = opts.isPro ? t.planPro : t.planLite;
    var period =
      formatDate(opts.periodEnd, locale) || t.noPeriod;
    var channel = channelLabel(t, opts.paymentMethod);
    var amountLine = opts.isPro ? t.amountUnknown : t.amountFree;
    var statusLine = opts.isPro ? t.statusPro : t.statusLite;
    var number = docNumber(opts.uid);
    var issued = formatDate(new Date(), locale) || new Date().toISOString().slice(0, 10);
    var logo =
      (opts.logoUrl && String(opts.logoUrl)) ||
      new URL('images/paychek-logo.svg', global.location.href).href;

    return (
      '<!DOCTYPE html><html lang="' +
      escapeHtml(locale) +
      '"><head><meta charset="UTF-8">' +
      '<meta name="viewport" content="width=device-width, initial-scale=1">' +
      '<title>' +
      escapeHtml(title) +
      ' — Paychek</title>' +
      '<style>' +
      ':root{--ink:#0f172a;--muted:#64748b;--line:#e2e8f0;--accent:#059669;--accent-soft:#ecfdf5;--paper:#ffffff;--wash:#f8fafc;}' +
      '*{box-sizing:border-box}body{margin:0;background:#e8eef3;color:var(--ink);font-family:Georgia,"Times New Roman",serif;}' +
      '.toolbar{position:sticky;top:0;z-index:5;display:flex;flex-wrap:wrap;gap:10px;align-items:center;justify-content:space-between;' +
      'padding:12px 18px;background:#0b1220;color:#e2e8f0;font-family:system-ui,-apple-system,sans-serif;font-size:13px;}' +
      '.toolbar p{margin:0;opacity:.75;max-width:42rem;line-height:1.4}' +
      '.toolbar .actions{display:flex;gap:8px;flex-wrap:wrap}' +
      '.toolbar button{appearance:none;border:0;border-radius:999px;padding:10px 16px;font-weight:700;font-size:11px;' +
      'letter-spacing:.08em;text-transform:uppercase;cursor:pointer}' +
      '.toolbar .primary{background:#fff;color:#0b1220}' +
      '.toolbar .ghost{background:transparent;color:#fff;border:1px solid rgba(255,255,255,.25)}' +
      '.sheet{width:min(820px,100%);margin:28px auto 48px;background:var(--paper);box-shadow:0 18px 50px rgba(15,23,42,.12);' +
      'border-radius:18px;overflow:hidden}' +
      '.accent-bar{height:6px;background:linear-gradient(90deg,#059669,#10b981,#34d399)}' +
      '.inner{padding:42px 48px 36px}' +
      '.header{display:flex;justify-content:space-between;gap:24px;align-items:flex-start;padding-bottom:28px;border-bottom:1px solid var(--line)}' +
      '.brand{display:flex;gap:14px;align-items:center}' +
      '.brand img{width:48px;height:48px}' +
      '.brand h1{margin:0;font-size:28px;letter-spacing:.04em;font-weight:800;font-family:system-ui,-apple-system,sans-serif}' +
      '.brand p{margin:4px 0 0;color:var(--muted);font-size:13px;font-family:system-ui,-apple-system,sans-serif}' +
      '.meta{text-align:right;font-family:system-ui,-apple-system,sans-serif}' +
      '.doc-type{display:inline-block;padding:6px 12px;border-radius:999px;background:var(--accent-soft);color:var(--accent);' +
      'font-size:11px;font-weight:800;letter-spacing:.12em;text-transform:uppercase;margin-bottom:10px}' +
      '.meta dl{margin:0;font-size:13px;color:var(--muted)}.meta dt{display:inline;font-weight:600}.meta dd{display:inline;margin:0 0 0 6px;color:var(--ink);font-weight:700}' +
      '.meta .row{margin-top:4px}' +
      '.grid{display:grid;grid-template-columns:1.1fr .9fr;gap:28px;margin:32px 0 28px;font-family:system-ui,-apple-system,sans-serif}' +
      '.card{background:var(--wash);border:1px solid var(--line);border-radius:14px;padding:18px 20px}' +
      '.card h2{margin:0 0 10px;font-size:11px;letter-spacing:.14em;text-transform:uppercase;color:var(--muted)}' +
      '.card .name{font-size:18px;font-weight:800;margin:0 0 6px}' +
      '.card .line{margin:0;color:var(--muted);font-size:14px;line-height:1.5}' +
      'table{width:100%;border-collapse:collapse;font-family:system-ui,-apple-system,sans-serif;margin-top:8px}' +
      'thead th{text-align:left;font-size:11px;letter-spacing:.1em;text-transform:uppercase;color:var(--muted);' +
      'padding:12px 10px;border-bottom:2px solid var(--ink)}' +
      'tbody td{padding:16px 10px;border-bottom:1px solid var(--line);vertical-align:top;font-size:14px}' +
      'tbody td.right{text-align:right;font-weight:700;white-space:nowrap}' +
      '.item-title{font-weight:800;font-size:15px;margin:0 0 6px}' +
      '.item-sub{margin:0;color:var(--muted);font-size:13px;line-height:1.45}' +
      '.totals{margin-top:22px;display:flex;justify-content:flex-end;font-family:system-ui,-apple-system,sans-serif}' +
      '.totals-box{min-width:min(100%,320px);background:var(--wash);border:1px solid var(--line);border-radius:14px;padding:16px 18px}' +
      '.totals-box .row{display:flex;justify-content:space-between;gap:16px;font-size:13px;padding:6px 0;color:var(--muted)}' +
      '.totals-box .row strong{color:var(--ink);font-size:14px;text-align:right;max-width:70%}' +
      '.note{margin-top:28px;padding:14px 16px;border-left:3px solid var(--accent);background:var(--accent-soft);' +
      'color:#065f46;font-size:13px;line-height:1.5;font-family:system-ui,-apple-system,sans-serif}' +
      '.footer{margin-top:36px;padding-top:22px;border-top:1px solid var(--line);display:flex;justify-content:space-between;' +
      'gap:20px;flex-wrap:wrap;font-family:system-ui,-apple-system,sans-serif;font-size:13px;color:var(--muted)}' +
      '.footer a{color:var(--accent);font-weight:700;text-decoration:none}' +
      '.thanks{font-size:15px;color:var(--ink);font-weight:700;margin:0 0 6px}' +
      '@media print{body{background:#fff}.toolbar{display:none!important}.sheet{margin:0;width:100%;box-shadow:none;border-radius:0}' +
      '.inner{padding:12mm 14mm}.accent-bar{print-color-adjust:exact;-webkit-print-color-adjust:exact}}' +
      '@media(max-width:700px){.inner{padding:28px 20px}.header,.grid{grid-template-columns:1fr;display:grid}.meta{text-align:left}}' +
      '</style></head><body>' +
      '<div class="toolbar"><p>' +
      escapeHtml(t.printHint) +
      '</p><div class="actions">' +
      '<button type="button" class="primary" onclick="window.print()">' +
      escapeHtml(t.printBtn) +
      '</button>' +
      '<button type="button" class="ghost" onclick="window.close()">' +
      escapeHtml(t.closeBtn) +
      '</button></div></div>' +
      '<article class="sheet"><div class="accent-bar"></div><div class="inner">' +
      '<header class="header"><div class="brand">' +
      '<img src="' +
      escapeHtml(logo) +
      '" alt="Paychek" width="48" height="48">' +
      '<div><h1>PAYCHEK</h1><p>' +
      escapeHtml(t.brandTagline) +
      '</p></div></div>' +
      '<div class="meta"><div class="doc-type">' +
      escapeHtml(title) +
      '</div><dl>' +
      '<div class="row"><dt>' +
      escapeHtml(t.invoiceNo) +
      '</dt><dd>' +
      escapeHtml(number) +
      '</dd></div>' +
      '<div class="row"><dt>' +
      escapeHtml(t.date) +
      '</dt><dd>' +
      escapeHtml(issued) +
      '</dd></div></dl></div></header>' +
      '<div class="grid"><section class="card"><h2>' +
      escapeHtml(t.billTo) +
      '</h2><p class="name">' +
      escapeHtml(name) +
      '</p><p class="line">' +
      escapeHtml(t.email) +
      ': ' +
      escapeHtml(email) +
      '</p></section>' +
      '<section class="card"><h2>' +
      escapeHtml(t.status) +
      '</h2><p class="name">' +
      escapeHtml(statusLine) +
      '</p><p class="line">' +
      escapeHtml(t.channel) +
      ': ' +
      escapeHtml(channel) +
      '</p></section></div>' +
      '<table><thead><tr><th>' +
      escapeHtml(t.description) +
      '</th><th class="right">' +
      escapeHtml(t.amount) +
      '</th></tr></thead><tbody><tr><td>' +
      '<p class="item-title">' +
      escapeHtml(plan) +
      '</p><p class="item-sub">' +
      escapeHtml(t.period) +
      ': ' +
      escapeHtml(period) +
      '<br>' +
      escapeHtml(t.channel) +
      ': ' +
      escapeHtml(channel) +
      '</p></td><td class="right">' +
      escapeHtml(amountLine) +
      '</td></tr></tbody></table>' +
      '<div class="totals"><div class="totals-box">' +
      '<div class="row"><span>' +
      escapeHtml(t.amount) +
      '</span><strong>' +
      escapeHtml(amountLine) +
      '</strong></div></div></div>' +
      '<p class="note">' +
      escapeHtml(t.amountNoteStore) +
      '</p>' +
      '<footer class="footer"><div><p class="thanks">' +
      escapeHtml(t.thanks) +
      '</p><p>' +
      escapeHtml(t.footerNote) +
      '</p></div><div>' +
      '<div>' +
      escapeHtml(t.support) +
      ': <a href="mailto:contact@paychek.pro">contact@paychek.pro</a></div>' +
      '<div><a href="' +
      escapeHtml(t.site) +
      '">' +
      escapeHtml(t.site.replace(/^https?:\/\//, '')) +
      '</a></div></div></footer>' +
      '</div></article></body></html>'
    );
  }

  function openDocument(opts) {
    opts = opts || {};
    if (!canDownloadDocument(opts)) {
      console.warn('[paychek] invoice download blocked: no paid entitlement');
      return false;
    }
    var html = buildHtml(opts);
    var w = global.open('', '_blank');
    if (!w) {
      console.warn('[paychek] invoice popup blocked');
      return false;
    }
    w.document.open();
    w.document.write(html);
    w.document.close();
    try {
      w.focus();
    } catch (_e) {}
    return true;
  }

  global.paychekInvoice = {
    openDocument: openDocument,
    buildHtml: buildHtml,
    isInvoiceStyle: isInvoiceStyle,
    canDownloadDocument: canDownloadDocument,
    buttonLabel: buttonLabel,
    downloadButtonLabel: downloadButtonLabel,
    strings: strings,
  };
})(window);

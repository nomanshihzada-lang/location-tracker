require "import"
import "android.content.Context"
import "android.content.Intent"
import "android.net.Uri"
import "android.location.LocationManager"
import "android.location.Geocoder"
import "java.util.Locale"
import "android.app.AlertDialog"
import "android.view.WindowManager"
import "android.content.ClipData"
import "android.widget.LinearLayout"
import "android.widget.TextView"
import "android.widget.ScrollView"
import "android.widget.Button"
import "android.graphics.Color"
import "android.view.Gravity"

-- 毓丕賱賲蹖 賲鬲睾蹖乇丕鬲 (Global State)
local currentLat = nil
local currentLon = nil
local currentAccuracy = 0
local selectedLangCode = "ur"
local selectedCountryCode = "PK"
local mainDialog = nil

local APP_HEADER = "Location Tracker Version 1.0 - Developed by All Technology Update 馃嚨馃嚢"

-- 丿賳蹖丕 讴蹖 丕蹃賲 夭亘丕賳賵诤 讴蹖 賲讴賲賱 賮蹃乇爻鬲
local languagesList = {
    {name = "丕乇丿賵 (Urdu)", code = "ur", country = "PK"},
    {name = "English (丕賳诏乇蹖夭蹖)", code = "en", country = "US"},
    {name = "丕賱毓乇亘賷丞 (Arabic)", code = "ar", country = "SA"},
    {name = "啶灌た啶ㄠ啶︵ (Hindi)", code = "hi", country = "IN"},
    {name = "倬賳噩丕亘蹖 / 啜┌啜溹ň啜﹢ (Punjabi)", code = "pa", country = "PK"},
    {name = "倬跉鬲賵 (Pashto)", code = "ps", country = "AF"},
    {name = "爻賳趯賷 (Sindhi)", code = "sd", country = "PK"},
    {name = "賮丕乇爻蹖 (Persian)", code = "fa", country = "IR"},
    {name = "唳唳傕Σ唳� (Bengali)", code = "bn", country = "BD"},
    {name = "T眉rk莽e (Turkish)", code = "tr", country = "TR"},
    {name = "Espa帽ol (Spanish)", code = "es", country = "ES"},
    {name = "Fran莽ais (French)", code = "fr", country = "FR"},
    {name = "Deutsch (German)", code = "de", country = "DE"},
    {name = "袪褍褋褋泻懈泄 (Russian)", code = "ru", country = "RU"},
    {name = "涓枃 (Chinese Simplified)", code = "zh", country = "CN"},
    {name = "鏃ユ湰瑾� (Japanese)", code = "ja", country = "JP"},
    {name = "頃滉淡鞏� (Korean)", code = "ko", country = "KR"},
    {name = "Portugu锚s (Portuguese)", code = "pt", country = "BR"},
    {name = "Italiano (Italian)", code = "it", country = "IT"},
    {name = "Nederlands (Dutch)", code = "nl", country = "NL"},
    {name = "Bahasa Indonesia (Indonesian)", code = "id", country = "ID"},
    {name = "Bahasa Melayu (Malay)", code = "ms", country = "MY"},
    {name = "喈む喈苦喁� (Tamil)", code = "ta", country = "IN"},
    {name = "喟む眴喟侧眮喟椸眮 (Telugu)", code = "te", country = "IN"},
    {name = "啶ぐ啶距啷€ (Marathi)", code = "mr", country = "IN"},
    {name = "嗒椸珌嗒溹嗒距喃€ (Gujarati)", code = "gu", country = "IN"},
    {name = "Kiswahili (Swahili)", code = "sw", country = "KE"},
    {name = "喙勦笚喔� (Thai)", code = "th", country = "TH"},
    {name = "Ti岷縩g Vi峄噒 (Vietnamese)", code = "vi", country = "VN"},
    {name = "Polski (Polish)", code = "pl", country = "PL"},
    {name = "校泻褉邪褩薪褋褜泻邪 (Ukrainian)", code = "uk", country = "UA"},
    {name = "螘位位畏谓喂魏维 (Greek)", code = "el", country = "GR"},
    {name = "Svenska (Swedish)", code = "sv", country = "SE"},
    {name = "Rom芒n膬 (Romanian)", code = "ro", country = "RO"},
    {name = "膶e拧tina (Czech)", code = "cs", country = "CZ"},
    {name = "Magyar (Hungarian)", code = "hu", country = "HU"},
    {name = "注讘专讬转 (Hebrew)", code = "he", country = "IL"},
    {name = "Filipino (Tagalog)", code = "fil", country = "PH"},
    {name = "啶ㄠ啶ぞ啶侧 (Nepali)", code = "ne", country = "NP"},
    {name = "喾冟窉喽傕穭喽� (Sinhala)", code = "si", country = "LK"}
}

-- 賲賳鬲禺亘 夭亘丕賳 讴蹝 賲胤丕亘賯 賱蹖亘賱夭
local function getLabels(lang)
    if lang == "ur" then
        return {
            title = APP_HEADER,
            fullAddr = "賲讴賲賱 倬鬲蹃",
            house = "诏诰乇 / 毓賲丕乇鬲 賳賲亘乇",
            street = "诏賱蹖 / 爻趹讴",
            area = "賲丨賱蹃 / 毓賱丕賯蹃",
            city = "卮蹃乇",
            district = "囟賱毓",
            province = "氐賵亘蹃",
            postal = "倬賵爻俟賱 讴賵趫",
            country = "賲賱讴",
            acc = "丿乇爻鬲诏蹖 (Accuracy)",
            meters = "賲蹖俟乇",
            copyAll = "賲讴賲賱 倬鬲蹃 讴丕倬蹖 讴乇蹖诤",
            copied = "讴丕倬蹖 蹃賵 诏蹖丕: ",
            copiedAll = "賲讴賲賱 賱賵讴蹖卮賳 讴賱倬 亘賵乇趫 倬乇 讴丕倬蹖 蹃賵 诏卅蹖 蹃蹝蹟",
            langBtn = "Languages (夭亘丕賳蹖诤)",
            feedbackBtn = "Feedback & Support",
            socialBtn = "Social Support",
            aboutBtn = "About",
            exitBtn = "Exit",
            closed = "亘賳丿 讴乇 丿蹖丕 诏蹖丕蹟",
            noAddr = "丕蹖趫乇蹖爻 讴蹖 鬲賮氐蹖賱丕鬲 丕爻 夭亘丕賳 賲蹖诤 丿爻鬲蹖丕亘 賳蹃蹖诤 蹃賵 爻讴蹖诤蹟"
        }
    elseif lang == "ar" then
        return {
            title = APP_HEADER,
            fullAddr = "丕賱毓賳賵丕賳 丕賱賰丕賲賱",
            house = "乇賯賲 丕賱賲賳夭賱 / 丕賱賲亘賳賶",
            street = "丕賱卮丕乇毓",
            area = "丕賱丨賷 / 丕賱賲賳胤賯丞",
            city = "丕賱賲丿賷賳丞",
            district = "丕賱賲賯丕胤毓丞",
            province = "丕賱賲丨丕賮馗丞 / 丕賱賵賱丕賷丞",
            postal = "丕賱乇賲夭 丕賱亘乇賷丿賷",
            country = "丕賱丿賵賱丞",
            acc = "丕賱丿賯丞",
            meters = "賲鬲乇",
            copyAll = "賳爻禺 丕賱毓賳賵丕賳 丕賱賰丕賲賱",
            copied = "鬲賲 丕賱賳爻禺: ",
            copiedAll = "鬲賲 賳爻禺 鬲賮丕氐賷賱 丕賱賲賵賯毓 亘丕賱賰丕賲賱 廿賱賶 丕賱丨丕賮馗丞.",
            langBtn = "Languages (丕賱賱睾丕鬲)",
            feedbackBtn = "Feedback & Support",
            socialBtn = "Social Support",
            aboutBtn = "About",
            exitBtn = "Exit",
            closed = "鬲賲 丕賱廿睾賱丕賯.",
            noAddr = "鬲毓匕乇 噩賱亘 鬲賮丕氐賷賱 丕賱毓賳賵丕賳 亘賴匕賴 丕賱賱睾丞."
        }
    elseif lang == "hi" then
        return {
            title = APP_HEADER,
            fullAddr = "啶啶班ぞ 啶い啶�",
            house = "啶啶距え / 啶さ啶� 啶膏啶栢啶ぞ",
            street = "啶椸げ啷€ / 啶膏ぁ啶监",
            area = "啶曕啶粪啶む啶� / 啶啶灌げ啷嵿げ啶�",
            city = "啶多す啶�",
            district = "啶溹た啶侧ぞ",
            province = "啶班ぞ啶溹啶� / 啶啶班ぞ啶傕い",
            postal = "啶た啶� 啶曕啶�",
            country = "啶︵啶�",
            acc = "啶膏啷€啶曕い啶� (Accuracy)",
            meters = "啶啶熰ぐ",
            copyAll = "啶啶班ぞ 啶い啶� 啶曕啶 啶曕ぐ啷囙",
            copied = "啶曕啶 啶灌 啶椸く啶�: ",
            copiedAll = "啶啶班ぞ 啶膏啶ムぞ啶� 啶掂た啶掂ぐ啶� 啶曕啶侧た啶が啷嬥ぐ啷嵿ぁ 啶ぐ 啶曕啶 啶灌 啶椸く啶� 啶灌啷�",
            langBtn = "Languages (啶ぞ啶粪ぞ啶忇)",
            feedbackBtn = "Feedback & Support",
            socialBtn = "Social Support",
            aboutBtn = "About",
            exitBtn = "Exit",
            closed = "啶啶� 啶曕ぐ 啶︵た啶ぞ 啶椸く啶距イ",
            noAddr = "啶囙じ 啶ぞ啶粪ぞ 啶啶� 啶い啷� 啶曕ぞ 啶掂た啶掂ぐ啶� 啶啶班ぞ啶啶� 啶ㄠす啷€啶� 啶灌 啶膏啶距イ"
        }
    else
        return {
            title = APP_HEADER,
            fullAddr = "Full Address",
            house = "House / Building No",
            street = "Street / Road",
            area = "Area / Locality",
            city = "City",
            district = "District",
            province = "Province / State",
            postal = "Postal Code",
            country = "Country",
            acc = "Accuracy",
            meters = "meters",
            copyAll = "Copy Full Address",
            copied = "Copied: ",
            copiedAll = "Full location details copied to clipboard.",
            langBtn = "Languages",
            feedbackBtn = "Feedback & Support",
            socialBtn = "Social Support",
            aboutBtn = "About",
            exitBtn = "Exit",
            closed = "Closed.",
            noAddr = "Address details could not be retrieved in this language."
        }
    end
end

local function showErrorDialog(errMsg)
    pcall(function()
        local builder = AlertDialog.Builder(service)
        builder.setTitle("Runtime Error")
        builder.setMessage(tostring(errMsg))
        builder.setPositiveButton("Copy", function(dialog, which)
            local cm = service.getSystemService(Context.CLIPBOARD_SERVICE)
            cm.setPrimaryClip(ClipData.newPlainText("Error", tostring(errMsg)))
            service.speak("Error copied")
        end)
        builder.setNegativeButton("Exit", nil)
        local dialog = builder.create()
        dialog.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY)
        dialog.show()
    end)
end

-- 鬲賲丕賲 讴诰賱蹝 蹃賵卅蹝 趫丕卅蹖賱丕诏 亘賳丿 讴乇 讴蹝 亘蹖乇賵賳蹖 賱賳讴 讴诰賵賱賳蹝 賵丕賱丕 賮賳讴卮賳
local function openUrlAndCloseApp(urlStr, activeSubDialog)
    pcall(function()
        if activeSubDialog then
            activeSubDialog.dismiss()
        end
        if mainDialog then
            mainDialog.dismiss()
            mainDialog = nil
        end
    end)
    pcall(function()
        local intent = Intent(Intent.ACTION_VIEW, Uri.parse(urlStr))
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        service.startActivity(intent)
    end)
end

-- Feedback & Support 趫丕卅蹖賱丕诏
local function showFeedbackDialog()
    local fbDialog = nil
    local builder = AlertDialog.Builder(service)
    builder.setTitle(APP_HEADER)

    local scrollView = ScrollView(service)
    local layout = LinearLayout(service)
    layout.setOrientation(LinearLayout.VERTICAL)
    layout.setPadding(40, 30, 40, 30)

    local headingTv = TextView(service)
    headingTv.setText(APP_HEADER .. "\nFeedback & Support")
    headingTv.setTextSize(18)
    headingTv.setTextColor(Color.WHITE)
    headingTv.setPadding(10, 10, 10, 15)
    headingTv.setFocusable(true)
    layout.addView(headingTv)

    local infoTv = TextView(service)
    infoTv.setText("For bug reports, feature suggestions, or technical assistance, contact our official WhatsApp support:")
    infoTv.setTextSize(16)
    infoTv.setTextColor(Color.WHITE)
    infoTv.setPadding(10, 10, 10, 20)
    infoTv.setFocusable(true)
    layout.addView(infoTv)

    local waBtn = Button(service)
    waBtn.setText("WhatsApp Support: +92 314 5406759")
    waBtn.setOnClickListener(function()
        openUrlAndCloseApp("https://wa.me/923145406759", fbDialog)
    end)
    layout.addView(waBtn)

    local copyNumBtn = Button(service)
    copyNumBtn.setText("Copy WhatsApp Number (03145406759)")
    copyNumBtn.setOnClickListener(function()
        local cm = service.getSystemService(Context.CLIPBOARD_SERVICE)
        cm.setPrimaryClip(ClipData.newPlainText("WhatsApp Number", "03145406759"))
        service.speak("WhatsApp number copied.")
    end)
    layout.addView(copyNumBtn)

    local backBtn = Button(service)
    backBtn.setText("Back")
    backBtn.setOnClickListener(function()
        if fbDialog then fbDialog.dismiss() end
    end)
    layout.addView(backBtn)

    scrollView.addView(layout)
    builder.setView(scrollView)
    fbDialog = builder.create()
    fbDialog.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY)
    fbDialog.show()
    service.speak("Location Tracker for version 1.0 developed by All Technology Update, Pakistan. Feedback and Support.")
end

-- Social Support 趫丕卅蹖賱丕诏
local function showSocialSupportDialog()
    local socDialog = nil
    local builder = AlertDialog.Builder(service)
    builder.setTitle("Social Support - All Technology Update 馃嚨馃嚢")

    local scrollView = ScrollView(service)
    local layout = LinearLayout(service)
    layout.setOrientation(LinearLayout.VERTICAL)
    layout.setPadding(40, 30, 40, 30)

    local descTv = TextView(service)
    descTv.setText("Join and follow All Technology Update on our official platforms for tutorials, plugins, and updates:")
    descTv.setTextSize(16)
    descTv.setTextColor(Color.WHITE)
    descTv.setPadding(10, 10, 10, 20)
    descTv.setFocusable(true)
    layout.addView(descTv)

    local ytBtn = Button(service)
    ytBtn.setText("All Technology Update - YouTube Channel")
    ytBtn.setOnClickListener(function()
        openUrlAndCloseApp("https://www.youtube.com/@0786-e9u", socDialog)
    end)
    layout.addView(ytBtn)

    local waChannelBtn = Button(service)
    waChannelBtn.setText("All Technology Update - WhatsApp Channel")
    waChannelBtn.setOnClickListener(function()
        openUrlAndCloseApp("https://whatsapp.com/channel/0029Vb8tKjlK0IBnVVzfv50a", socDialog)
    end)
    layout.addView(waChannelBtn)

    local waGroupBtn = Button(service)
    waGroupBtn.setText("All Technology Update - WhatsApp Group")
    waGroupBtn.setOnClickListener(function()
        openUrlAndCloseApp("https://chat.whatsapp.com/JGz8fgOFXth9cTWh3IRF7s?s=cl&p=a&iam=2", socDialog)
    end)
    layout.addView(waGroupBtn)

    local backBtn = Button(service)
    backBtn.setText("Back")
    backBtn.setOnClickListener(function()
        if socDialog then socDialog.dismiss() end
    end)
    layout.addView(backBtn)

    scrollView.addView(layout)
    builder.setView(scrollView)
    socDialog = builder.create()
    socDialog.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY)
    socDialog.show()
    service.speak("Social Support. Follow All Technology Update on YouTube, WhatsApp Channel, and WhatsApp Group.")
end

-- About 趫丕卅蹖賱丕诏
local function showAboutDialog()
    local aboutDialog = nil
    local builder = AlertDialog.Builder(service)
    builder.setTitle(APP_HEADER)

    local scrollView = ScrollView(service)
    local layout = LinearLayout(service)
    layout.setOrientation(LinearLayout.VERTICAL)
    layout.setPadding(40, 30, 40, 30)

    local aboutText = [[Location Tracker Version 1.0 - Developed by All Technology Update 馃嚨馃嚢
Project: Noman Khan
Present: Pakistan 馃嚨馃嚢

Description:
Location Tracker is a specialized accessibility plugin designed for Jieshuo (Commentary Screen Reader) users. Unlike basic location tools that only announce the city name, this extension retrieves real-time GPS and network coordinates along with detailed reverse-geocoded address components including house or building number, street name, neighborhood, city, district, province, postal code, and country.

Key Features:
- Complete swipe-friendly accessibility layout for effortless screen reader navigation.
- Multi-language support allowing instant conversion of location details and summaries into dozens of global and regional languages.
- One-tap copying for individual address lines or the complete address with a direct Google Maps link.
- Real-time GPS accuracy indicator in meters.]]

    local tv = TextView(service)
    tv.setText(aboutText)
    tv.setTextSize(16)
    tv.setTextColor(Color.WHITE)
    tv.setPadding(10, 10, 10, 25)
    tv.setFocusable(true)
    layout.addView(tv)

    local backBtn = Button(service)
    backBtn.setText("Back")
    backBtn.setOnClickListener(function()
        if aboutDialog then aboutDialog.dismiss() end
    end)
    layout.addView(backBtn)

    scrollView.addView(layout)
    builder.setView(scrollView)
    aboutDialog = builder.create()
    aboutDialog.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY)
    aboutDialog.show()
    service.speak("Location Tracker for version 1.0 developed by All Technology Update, Pakistan. Project Noman Khan.")
end

-- 丌诏蹝 鬲毓乇蹖賮 卮丿蹃 賮賳讴卮賳 讴丕 丨賵丕賱蹃
local renderLocationInSelectedLanguage

-- Languages 丕賳鬲禺丕亘 讴丕 趫丕卅蹖賱丕诏
local function showLanguagesDialog()
    local langDialog = nil
    local builder = AlertDialog.Builder(service)
    builder.setTitle("Select Language / 夭亘丕賳 賲賳鬲禺亘 讴乇蹖诤")

    local scrollView = ScrollView(service)
    local layout = LinearLayout(service)
    layout.setOrientation(LinearLayout.VERTICAL)
    layout.setPadding(35, 25, 35, 25)

    for _, item in ipairs(languagesList) do
        local btn = Button(service)
        btn.setText(item.name)
        btn.setOnClickListener(function()
            selectedLangCode = item.code
            selectedCountryCode = item.country
            if langDialog then langDialog.dismiss() end
            if mainDialog then mainDialog.dismiss() end
            service.speak("Language changed to " .. item.name)
            renderLocationInSelectedLanguage()
        end)
        layout.addView(btn)
    end

    local backBtn = Button(service)
    backBtn.setText("Back")
    backBtn.setOnClickListener(function()
        if langDialog then langDialog.dismiss() end
    end)
    layout.addView(backBtn)

    scrollView.addView(layout)
    builder.setView(scrollView)
    langDialog = builder.create()
    langDialog.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY)
    langDialog.show()
    service.speak("Languages list opened. Swipe to choose a language.")
end

-- 賲乇讴夭蹖 賱賵讴蹖卮賳 趫丕卅蹖賱丕诏 丿讴诰丕賳蹝 賵丕賱丕 賮賳讴卮賳
local function showLocationDialog(itemsList, fullCopyText, spokenSummary, labels)
    local builder = AlertDialog.Builder(service)
    builder.setTitle(labels.title)

    local scrollView = ScrollView(service)
    local mainLayout = LinearLayout(service)
    mainLayout.setOrientation(LinearLayout.VERTICAL)
    mainLayout.setPadding(40, 30, 40, 30)

    -- 丕賵倬乇 賵丕囟丨 蹃蹖趫賳诏 鬲丕讴蹃 爻賵丕卅倬 賲蹖诤 爻亘 爻蹝 倬蹃賱蹝 倬趹诰蹖 噩丕卅蹝
    local topHeaderTv = TextView(service)
    topHeaderTv.setText(APP_HEADER)
    topHeaderTv.setTextSize(18)
    topHeaderTv.setTextColor(Color.WHITE)
    topHeaderTv.setPadding(15, 10, 15, 20)
    topHeaderTv.setFocusable(true)
    mainLayout.addView(topHeaderTv)

    -- 蹃乇 鬲賮氐蹖賱 讴蹝 賱蹖蹝 丕賱诏 賮賵讴爻 丕蹖亘賱 TextView 鬲丕讴蹃 爻賵丕卅倬 讴乇 讴蹝 倬趹诰丕 噩丕 爻讴蹝
    for _, line in ipairs(itemsList) do
        local tv = TextView(service)
        tv.setText(line)
        tv.setTextSize(17)
        tv.setTextColor(Color.WHITE)
        tv.setPadding(15, 18, 15, 18)
        tv.setFocusable(true)
        tv.setClickable(true)
        tv.setOnClickListener(function()
            local cm = service.getSystemService(Context.CLIPBOARD_SERVICE)
            cm.setPrimaryClip(ClipData.newPlainText("Location Detail", line))
            service.speak(labels.copied .. line)
        end)
        mainLayout.addView(tv)
    end

    -- 丕蹖讴卮賳 亘俟賳
    local copyBtn = Button(service)
    copyBtn.setText(labels.copyAll)
    copyBtn.setOnClickListener(function()
        local cm = service.getSystemService(Context.CLIPBOARD_SERVICE)
        cm.setPrimaryClip(ClipData.newPlainText("Full Location", fullCopyText))
        service.speak(labels.copiedAll)
    end)
    mainLayout.addView(copyBtn)

    local langBtn = Button(service)
    langBtn.setText(labels.langBtn)
    langBtn.setOnClickListener(function()
        showLanguagesDialog()
    end)
    mainLayout.addView(langBtn)

    local feedbackBtn = Button(service)
    feedbackBtn.setText(labels.feedbackBtn)
    feedbackBtn.setOnClickListener(function()
        showFeedbackDialog()
    end)
    mainLayout.addView(feedbackBtn)

    local socialBtn = Button(service)
    socialBtn.setText(labels.socialBtn)
    socialBtn.setOnClickListener(function()
        showSocialSupportDialog()
    end)
    mainLayout.addView(socialBtn)

    local aboutBtn = Button(service)
    aboutBtn.setText(labels.aboutBtn)
    aboutBtn.setOnClickListener(function()
        showAboutDialog()
    end)
    mainLayout.addView(aboutBtn)

    local exitBtn = Button(service)
    exitBtn.setText(labels.exitBtn)
    exitBtn.setOnClickListener(function()
        if mainDialog then
            mainDialog.dismiss()
            mainDialog = nil
        end
        service.speak(labels.closed)
    end)
    mainLayout.addView(exitBtn)

    scrollView.addView(mainLayout)
    builder.setView(scrollView)
    builder.setCancelable(true)

    mainDialog = builder.create()
    mainDialog.getWindow().setType(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY)
    mainDialog.show()

    -- 趫丕卅蹖賱丕诏 讴诰賱鬲蹝 蹃蹖 蹃蹖趫賳诏 丕賵乇 賲讴賲賱 賱賵讴蹖卮賳 倬趹诰 讴乇 爻賳丕賳丕
    local openingSpeech = "Location Tracker for version 1.0 developed by All Technology Update, Pakistan. " .. spokenSummary
    service.postSpeak(450, openingSpeech)
end

-- 賲賳鬲禺亘 夭亘丕賳 賲蹖诤 Geocoder 讴蹝 匕乇蹖毓蹝 丕蹖趫乇蹖爻 丕賵乇 爻賲乇蹖 鬲蹖丕乇 讴乇賳丕
renderLocationInSelectedLanguage = function()
    local ok, err = pcall(function()
        local labels = getLabels(selectedLangCode)
        local targetLocale = Locale(selectedLangCode, selectedCountryCode)

        local displayItems = {}
        local spokenDetails = {}

        local geoOk, geoErr = pcall(function()
            local geocoder = Geocoder(service, targetLocale)
            local addresses = geocoder.getFromLocation(currentLat, currentLon, 1)

            if addresses and addresses.size() > 0 then
                local addr = addresses.get(0)

                local fullAddress = addr.getAddressLine(0) or ""
                local houseNumber = addr.getSubThoroughfare() or ""
                local street = addr.getThoroughfare() or ""
                local area = addr.getSubLocality() or ""
                local city = addr.getLocality() or ""
                local district = addr.getSubAdminArea() or ""
                local province = addr.getAdminArea() or ""
                local postalCode = addr.getPostalCode() or ""
                local country = addr.getCountryName() or ""

                if fullAddress ~= "" then
                    table.insert(displayItems, labels.fullAddr .. ": " .. fullAddress)
                    table.insert(spokenDetails, labels.fullAddr .. ": " .. fullAddress)
                end
                if houseNumber ~= "" then
                    table.insert(displayItems, labels.house .. ": " .. houseNumber)
                    table.insert(spokenDetails, labels.house .. ": " .. houseNumber)
                end
                if street ~= "" then
                    table.insert(displayItems, labels.street .. ": " .. street)
                    table.insert(spokenDetails, labels.street .. ": " .. street)
                end
                if area ~= "" then
                    table.insert(displayItems, labels.area .. ": " .. area)
                    table.insert(spokenDetails, labels.area .. ": " .. area)
                end
                if city ~= "" then
                    table.insert(displayItems, labels.city .. ": " .. city)
                    table.insert(spokenDetails, labels.city .. ": " .. city)
                end
                if district ~= "" then
                    table.insert(displayItems, labels.district .. ": " .. district)
                    table.insert(spokenDetails, labels.district .. ": " .. district)
                end
                if province ~= "" then
                    table.insert(displayItems, labels.province .. ": " .. province)
                    table.insert(spokenDetails, labels.province .. ": " .. province)
                end
                if postalCode ~= "" then
                    table.insert(displayItems, labels.postal .. ": " .. postalCode)
                    table.insert(spokenDetails, labels.postal .. ": " .. postalCode)
                end
                if country ~= "" then
                    table.insert(displayItems, labels.country .. ": " .. country)
                    table.insert(spokenDetails, labels.country .. ": " .. country)
                end
            else
                table.insert(displayItems, labels.noAddr)
                table.insert(spokenDetails, labels.noAddr)
            end
        end)

        local latLine = string.format("Latitude: %.6f", currentLat)
        local lonLine = string.format("Longitude: %.6f", currentLon)
        local accLine = string.format("%s: ~%d %s", labels.acc, currentAccuracy, labels.meters)
        local mapsLink = string.format("Google Maps: https://maps.google.com/?q=%.6f,%.6f", currentLat, currentLon)

        table.insert(displayItems, latLine)
        table.insert(displayItems, lonLine)
        table.insert(displayItems, accLine)
        table.insert(displayItems, mapsLink)

        local coordSpoken = string.format("Latitude %.5f, Longitude %.5f. %s %d %s.", currentLat, currentLon, labels.acc, currentAccuracy, labels.meters)
        local finalSpoken = table.concat(spokenDetails, ". ") .. ". " .. coordSpoken
        local fullCopyText = APP_HEADER .. "\n" .. table.concat(displayItems, "\n")

        showLocationDialog(displayItems, fullCopyText, finalSpoken, labels)
    end)

    if not ok then
        showErrorDialog(err)
    end
end

local ok, mainErr = pcall(function()
    service.vibrate(50)
    service.playSoundTick()
    service.speak("賲賵噩賵丿蹃 賱賵讴蹖卮賳 讴蹖 鬲賮氐蹖賱丕鬲 丨丕氐賱 讴蹖 噩丕 乇蹃蹖 蹃蹖诤貙 亘乇丕蹃 讴乇賲 丕賳鬲馗丕乇 讴乇蹖诤蹟")

    local locationManager = service.getSystemService(Context.LOCATION_SERVICE)

    local gpsLocation = nil
    local netLocation = nil

    pcall(function()
        gpsLocation = locationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER)
    end)

    pcall(function()
        netLocation = locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER)
    end)

    local bestLocation = nil
    if gpsLocation and netLocation then
        if gpsLocation.getTime() > netLocation.getTime() then
            bestLocation = gpsLocation
        else
            bestLocation = netLocation
        end
    elseif gpsLocation then
        bestLocation = gpsLocation
    elseif netLocation then
        bestLocation = netLocation
    end

    if bestLocation then
        currentLat = bestLocation.getLatitude()
        currentLon = bestLocation.getLongitude()
        currentAccuracy = math.floor(bestLocation.getAccuracy())

        -- 賲賳鬲禺亘 夭亘丕賳 賲蹖诤 賱賵讴蹖卮賳 趫丕卅蹖賱丕诏 讴诰賵賱賳丕
        renderLocationInSelectedLanguage()
    else
        service.beep()
        service.speak("賲毓匕乇鬲貙 賱賵讴蹖卮賳 丨丕氐賱 賳蹃蹖诤 蹃賵 爻讴蹖蹟 亘乇丕蹃 讴乇賲 蹖賯蹖賳蹖 亘賳丕卅蹖诤 讴蹃 賮賵賳 讴蹖 賱賵讴蹖卮賳 丌賳 蹃蹝 丕賵乇 Jieshuo 讴賵 賱賵讴蹖卮賳 讴蹖 丕噩丕夭鬲 丿蹖 诏卅蹖 蹃蹝蹟")
    end
end)

if not ok then
    showErrorDialog(mainErr)
end

return true

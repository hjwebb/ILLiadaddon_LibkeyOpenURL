--openURLlibkey.lua (version 3.1)
-- openURL.lua (version 0.1, 5/5/2010)
-- Kevin Reiss kevin.reiss@mail.cuny.edu
--
-- Opens OpenURL menu 
--updated March 29, 2020 Heidi Webb for Chromium and doi
--updated September 2023 Heidi Webb 

-- Load the .NET System Assembly
luanet.load_assembly("System");
Types = {};
Types["Process"] = luanet.import_type("System.Diagnostics.Process");


-- define your OpenURL resolver
local settings = {};
settings.myArticleResolver = GetSetting("OpenUrlBaseArticle");
settings.myBookResolver = GetSetting("OpenUrlBaseBook");
settings.mylibkeyid = GetSetting("LibkeyID");
settings.myBranding = GetSetting("OpenUrlBrand");
-- set autoSearch to true for this script to automatically run the search when the request is opened.
settings.autoSearch = GetSetting("AutoSearch");

-- don't change anything below this line
local interfaceMngr = nil;
local OpenURLSearchForm = {};

require "Atlas.AtlasHelpers";

OpenURLSearchForm.Form = nil;
OpenURLSearchForm.Browser = nil;
OpenURLSearchForm.RibbonPage = nil;

function Init()
		interfaceMngr = GetInterfaceManager();
		OpenURLSearchForm.Form = interfaceMngr:CreateForm(settings.myBranding, "Search");
	    
		-- Add a browser
		OpenURLSearchForm.Browser = OpenURLSearchForm.Form:CreateBrowser(settings.myBranding, "Search Browser", "Search", "Chromium");
	    
		-- Hide the text label
		OpenURLSearchForm.Browser.TextVisible = false;
		OpenURLSearchForm.Browser:CollapseTextPlaceholder();
	
		-- Since we didn't create a ribbon explicitly before creating our browser, it will have created one using the name we passed the CreateBrowser method.  We can retrieve that one and add our buttons to it.
		OpenURLSearchForm.RibbonPage = OpenURLSearchForm.Form:GetRibbonPage("Search");
		
		OpenURLSearchForm.RibbonPage:CreateButton("Search LibKey", GetClientImage("Search32"), "SearchLibkey", "DOI and PMID");
		OpenURLSearchForm.RibbonPage:CreateButton("Search OpenURL", GetClientImage("Search32"), "SearchOpenURL", "OpenURL Search");
		OpenURLSearchForm.RibbonPage:CreateButton("Open in Browser", GetClientImage("Web32"), "OpenInDefaultBrowser", "Utility");

		OpenURLSearchForm.Form:Show();
		
		if settings.autoSearch then
			SearchLibkey();
		end
end

function SearchLibkey()
	
		if GetFieldValue("Transaction", "DOI") ~= "" then
			local myDOI = GetFieldValue("Transaction", "DOI");
			myURL = "https://libkey.io/libraries/" .. settings.mylibkeyid .. "/" .. myDOI;
		elseif GetFieldValue("Transaction", "PMID") ~= "" then
			local myPMID = GetFieldValue("Transaction", "PMID");
			myURL = "https://libkey.io/libraries/" .. settings.mylibkeyid .. "/" .. myPMID;
		elseif GetFieldValue("Transaction", "RequestType") == "Article" then
			-- build URL for articles
			local myGenre = "genre=article";
			local tempYear = GetFieldValue("Transaction", "PhotoJournalYear");
				if tempYear:len()>4 then
					tempYear=tempYear:match("%d%d%d%d")
				end
			local myYear = "&rft.date=" .. tempYear;
			local myISxN = "&rft.issn=" .. GetFieldValue("Transaction", "ISSN");
			local myAtitle = "&rft.atitle=" .. GetFieldValue("Transaction", "PhotoArticleTitle");
			local myVolume = "&rft.volume=" .. GetFieldValue("Transaction", "PhotoJournalVolume");
			local myIssue = "&rft.issue=" .. GetFieldValue("Transaction", "PhotoJournalIssue");
			local myPages = "&rft.spage=" .. GetFieldValue("Transaction", "PhotoJournalInclusivePages");
			local myTitle = "&rft.title=" .. GetFieldValue("Transaction", "PhotoJournalTitle");
			local myAuthor = "&rft.au=" .. GetFieldValue("Transaction", "PhotoArticleAuthor");
			local myDOI = "&rft.doi=" .. GetFieldValue("Transaction", "DOI");
			myURL = settings.myArticleResolver .. "?" .. myGenre .. myYear .. myISxN .. myAtitle .. myVolume .. myIssue .. myPages.. myTitle .. myAuthor .. myDOI;
		else
			-- build URL for books and other 'returnables'
			local myGenre = "genre=book";
			local tempYear = GetFieldValue("Transaction", "LoanDate");
				if tempYear:len()>4 then
					tempYear=tempYear:match("%d%d%d%d")
				end
			local myYear = "&rft.date=" .. tempYear;
			local myISxN = "&rft.isbn=" .. GetFieldValue("Transaction", "ISSN");
			local myTitle = "&rft.title=" .. GetFieldValue("Transaction", "LoanTitle");
			local myAuthor = "&rft.au=" .. GetFieldValue("Transaction", "LoanAuthor");
			myURL = settings.myBookResolver .. "?" .. myGenre .. myYear .. myISxN .. myTitle .. myAuthor;
		end
	
		OpenURLSearchForm.Browser:Navigate(myURL);
	
end

function SearchOpenURL()
	
		if GetFieldValue("Transaction", "RequestType") == "Article" then
			-- build URL for articles
			local myGenre = "genre=article";
			local tempYear = GetFieldValue("Transaction", "PhotoJournalYear");
				if tempYear:len()>4 then
					tempYear=tempYear:match("%d%d%d%d")
				end
			local myYear = "&rft.date=" .. tempYear;
			local myISxN = "&rft.issn=" .. GetFieldValue("Transaction", "ISSN");
			local myAtitle = "&rft.atitle=" .. GetFieldValue("Transaction", "PhotoArticleTitle");
			local myVolume = "&rft.volume=" .. GetFieldValue("Transaction", "PhotoJournalVolume");
			local myIssue = "&rft.issue=" .. GetFieldValue("Transaction", "PhotoJournalIssue");
			local myPages = "&rft.spage=" .. GetFieldValue("Transaction", "PhotoJournalInclusivePages");
			local myTitle = "&rft.title=" .. GetFieldValue("Transaction", "PhotoJournalTitle");
			local myAuthor = "&rft.au=" .. GetFieldValue("Transaction", "PhotoArticleAuthor");
			local myDOI = "&rft.doi=" .. GetFieldValue("Transaction", "DOI");
			myURL = settings.myArticleResolver .. "?" .. myGenre .. myYear .. myISxN .. myAtitle .. myVolume .. myIssue .. myPages.. myTitle .. myAuthor .. myDOI;
		else
			-- build URL for books and other 'returnables'
			local myGenre = "genre=book";
			local tempYear = GetFieldValue("Transaction", "LoanDate");
				if tempYear:len()>4 then
					tempYear=tempYear:match("%d%d%d%d")
				end
			local myYear = "&rft.date=" .. tempYear;
			local myISxN = "&rft.isbn=" .. GetFieldValue("Transaction", "ISSN");
			local myTitle = "&rft.title=" .. GetFieldValue("Transaction", "LoanTitle");
			local myAuthor = "&rft.au=" .. GetFieldValue("Transaction", "LoanAuthor");
			myURL = settings.myBookResolver .. "?" .. myGenre .. myYear .. myISxN .. myTitle .. myAuthor;
		end
	
		OpenURLSearchForm.Browser:Navigate(myURL);
	
end

function OpenInDefaultBrowser()
	local currentUrl = OpenURLSearchForm.Browser.Address;
	
	if (currentUrl and currentUrl ~= "")then
		LogDebug("Opening Browser URL in default browser: " .. currentUrl);

		local process = Types["Process"]();
		process.StartInfo.FileName = currentUrl;
		process.StartInfo.UseShellExecute = true;
		process:Start();
	end
end

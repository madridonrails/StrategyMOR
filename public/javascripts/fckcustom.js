// CHANGE FOR APPS HOSTED IN SUBDIRECTORY
FCKRelativePath = '';

// DON'T CHANGE THESE
FCKConfig.LinkBrowserURL = FCKConfig.BasePath + 'filemanager/browser/default/browser.html?Connector='+FCKRelativePath+'/fckeditor/command';
FCKConfig.ImageBrowserURL = FCKConfig.BasePath + 'filemanager/browser/default/browser.html?Type=images&Connector='+FCKRelativePath+'/fckeditor/command';
FCKConfig.FlashBrowserURL = FCKConfig.BasePath + 'filemanager/browser/default/browser.html?Type=flash&Connector='+FCKRelativePath+'/fckeditor/command';

FCKConfig.LinkUploadURL = FCKRelativePath+'/fckeditor/upload';
FCKConfig.ImageUploadURL = FCKRelativePath+'/fckeditor/upload?Type=images';
FCKConfig.FlashUploadURL = FCKRelativePath+'/fckeditor/upload?Type=flash';
FCKConfig.AllowQueryStringDebug = false;
FCKConfig.SpellChecker = 'SpellerPages';

// ONLY CHANGE BELOW HERE
FCKConfig.SkinPath = FCKConfig.BasePath + 'skins/silver/';
FCKConfig.EditorAreaCSS = '/stylesheets/content/styles_for_html_editor.css' ;
FCKConfig.TemplatesXmlPath='/javascripts/fcktemplates.xml'
FCKConfig.StylesXmlPath = '/javascripts/fckstyles.xml' ;

FCKConfig.ToolbarSets["Simple"] = [
	['Source','-','-','Templates'],
	['Cut','Copy','Paste','PasteWord','-','Print','SpellCheck'],
	['Undo','Redo','-','Find','Replace','-','SelectAll'],
	'/',
	['Bold','Italic','Underline','StrikeThrough','-','Subscript','Superscript'],
	['OrderedList','UnorderedList','-','Outdent','Indent'],
	['JustifyLeft','JustifyCenter','JustifyRight','JustifyFull'],
	['Link','Unlink'],
	'/',
	['Image','Table','Rule','Smiley'],
	['FontName','FontSize'],
	['TextColor','BGColor'],
	['-','About']
] ;

FCKConfig.ToolbarSets["content"] = [
	['Source', '-','NewPage','Templates'],
	['Cut','Copy','Paste','PasteText','PasteWord'],
	['Undo','Redo','-','Find','Replace'],	
	['Link','Unlink'],
	['Image','Table','Rule'],	
	['OrderedList','UnorderedList','-','Outdent','Indent'],
	['Bold','Italic','Underline','StrikeThrough','-','Subscript','Superscript','Style','RemoveFormat'],
	['JustifyLeft','JustifyCenter','JustifyRight','JustifyFull']
] ;

FCKConfig.AutoDetectLanguage = false ;
FCKConfig.DefaultLanguage = "es" ;
FCKConfig.TemplateReplaceAll = false ;


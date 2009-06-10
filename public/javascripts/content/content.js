var Content= new Object();
    Content.toggle_live_editors = function() {
      $$("div.live_editor").each(function hide(el){el.toggle()});
      $$("div.content_holder").each(function border(el){
            el.style.borderWidth=(el.style.borderWidth.indexOf('1px')==-1) ? ('1px') : ('0px'); 
            });
    };
   
    Content.content_edit_window = function(page_path,area,content_type,i_width,i_height){
        if (!i_width ) i_width = 650;
        if (!i_height ) i_height = 500;
        
        Content.modal_window ('Editar Contenido', '/content/'+content_type+'_content_edit', 'page_path=' + page_path + '&area=' +area,i_width,i_height );        
    };

    Content.modal_window = function(str_title,str_url,str_url_params,i_width,i_height){
        if (!i_width ) i_width = 650;
        if (!i_height ) i_height = 500;
        
        win = new Window('window_id', {title: str_title, width:i_width, height:i_height, resizable:false,closable:false,maximizable:false,minimizable:false,url:str_url+'?' + str_url_params});                         
        win.setDestroyOnClose(); 
        win.showCenter(true);
    };
    
        
    Content.close_focused = function( b_close_directly ) {
        if ( b_close_directly || confirm ('¿Cerrar la ventana y perder los cambios?') )
         {
            if (Windows.getFocusedWindow())
                Windows.close(Windows.getFocusedWindow().getId());
            else
                window.parent.Windows.close(window.parent.Windows.getFocusedWindow().getId());
          }
    };
    
    Content.parent_content_from_remote = function (parent_id,request) {
        top.$(parent_id).innerHTML=request.responseText
    };
    
    Content.visit_content_page_from_popup = function (page_path,b_close_directly) {
        if ( b_close_directly || confirm ('¿Cerrar la ventana y navegar a otra página?') )
            window.parent.location.href = '/web' + page_path;
    };

    function setActiveStyleSheet(title) {
       var i, a, main;
       for(i=0; (a = document.getElementsByTagName("link")[i]); i++) {
         if(a.getAttribute("rel").indexOf("style") != -1
            && a.getAttribute("title")) {
           a.disabled = true;
           if(a.getAttribute("title") == title) a.disabled = false;
         }
       }
    }



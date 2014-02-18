/*
 * Copyright (c) 2010 Freshlimestudio
 */


var actions_height;
var min_top;
var min_left;
var max_top;
var max_left;

// Функция задания размеров основным элементам рабочей области
function resize() {
    actions_height = $("div#actions").outerHeight(true);
    if ($("div#actions").css('display') == 'none') actions_height = 0;

    $('div#page').css('top', actions_height);
    $('div#page').css('height', $(window).height() - actions_height);
    $('div#page').css('width', $(window).width() - 2);

    $('div#add-rows-button').css('top', $('#page').height() - 16)

    $('div#head').css('width', $('#page').width() - 111 - 101);

    $('div#num').css('height', $('#page').height() - 40);

    $('div#body').css('height', $('#page').height() - 24);
    $('div#body').css('width', $('#page').width() - 111 - 101);

    $('div#body-po').css('height', $('#page').height() - 40);

    // Запоминание максимальных и минимальных параметров для хелперов.
    // Чтобы те не вылазили за переделы видимой области
    min_top = $("#head").offset().top + $("#head").outerHeight(true);
    min_left = $("#body-po").offset().left + $("#body-po").outerWidth(true);
    max_top = $("#body").offset().top + $("#body").outerHeight(true) - 15;
    // - 15 Добавить если еще нужно рисовать хелпер вокруг ячейки
    max_left = $("#body").offset().left + $("#body").outerWidth(true) ;
}

// Создает кнопки "Visible?".
// TODO: Очень ресурсоемкая функция. Нужен аналог.
function visible_row(id) {
    if (id == "all")
        $(".visible-row").button();
    else
        $("#row_" + id).button();
}

var role = false;
// устанавливает роль пользователя
function set_role(r) {
    role = r;
}

// Обрабатывает нажатие кнопочки "Visible?". Отсылает аяксовый запрос на
// обновлени строки
function change_visible_row(id) {
    var element = '';
    if (id == "all")
        element = $("#num .visible-row");
    else
        element = $("#row_" + id);

    element.change(function () {
        $("#body_" + this.id).toggleClass('invisible-row');
        $("#body-po_" + this.id).toggleClass('invisible-row');
        $(this).parent().toggleClass('invisible-row');

        var id = this.id.split("row_").join("");
        if ($(this).attr('checked')) {
            $.ajax({
                url: "/spreadsheets/enable/" + id,
                success: function() {
                    jQuery.noticeAdd({text: 'Row #' + id + ' successfully visibled.'})
                },
                error: function(XMLHttpRequest, textStatus, errorThrown) {
                    var text = "Error: " + XMLHttpRequest.status + " " + XMLHttpRequest.statusText
                    jQuery.noticeAdd({text: text, type: "error"})
                }
            });
        } else {
            $.ajax({
                url: "/spreadsheets/disable/" + id,
                success: function() {
                    jQuery.noticeAdd({text: 'Row #' + id + ' successfully unvisibled.'})
                },
                error: function(XMLHttpRequest, textStatus, errorThrown) {
                    var text = "Error: " + XMLHttpRequest.status + " " + XMLHttpRequest.statusText
                    jQuery.noticeAdd({text: text, type: "error"})
                }
            });
        }

    });
}

// Запоминает, какое поле сортировалось последним
var sort_field = '';
// Переменная для храниения параметров фильтрования
var filter_params = '';
// Переменная для хрнения типа бизнеса
var business = 'cent';
// Функция сортировки данных по конкретному полю
function sort(obj, field) {
    $('#head img').remove();
    $('#appendix img').remove();
    $('#po-field img').remove();

    var desc = '&desc=true&';

    if (sort_field != field) {
        sort_field = field;
        desc = '&';
        $(obj).append(' <img src="/images/sort.png" alt="" />')
    } else {
        sort_field = '';
//        desc = '&desc=true&';
        $(obj).append(' <img src="/images/sort_desc.png" alt="" />')
    }
    
    $.ajax({
        url: "/spreadsheets?sort=" + field + desc + filter_params,
        beforeSend: function() {
            $("#spinner-dialog").dialog("open");
        },
        success: function() {
            $("#spinner-dialog").dialog("close");
            //jQuery.noticeAdd({text: 'Row ' + id + ' successfully unvisibled.'})
        },
        error: function(XMLHttpRequest, textStatus, errorThrown) {
            var text = "Error: " + XMLHttpRequest.status + " " + XMLHttpRequest.statusText
            jQuery.noticeAdd({text: text, type: "error"})
        }
    });
}

// Перезаписывает параметры фильтрования
function rewrite_filter_params(params) {
    if (params != "")
        filter_params = params + "&";
    else
        filter_params = params;
}

// 
function set_business(b) {
    business = b;
}

// Прокручивает таблицу вверх
function scroll_top() {
    document.getElementById('body').scrollTop = 0;
    document.getElementById('body-po').scrollTop = 0;
}

// Прокручивает таблицу
function scroll_to(top) {
    document.getElementById('body').scrollTop = top;
}

// Форматирует текущую дату до нужного нам вида.
function formatDate(date){
    var formated = "";

    formated += (date.getMonth() < 10 ? '0' : '') + (date.getMonth() + 1);
    formated += "/";
    formated += (date.getDate() < 10 ? '0' : '') + date.getDate();
    formated += "/";
    formated += date.getFullYear();

    return formated;
}

// Хранит список доступных для редактирования полей.
var editable_fields = Array;
// Устанавливает, какие поля могут редактироваться.
function set_editable_fields(fields) {
    editable_fields = fields;
}

//context menu
function set_context_menu() {
    //прибивает контекстное меню
    $('#body table td.edited-cell, #body-po table td.edited-cell').bind('contextmenu', function() {
        return false;
    });

    //вызывает свое контекстное меню для левой кнопки мыши
    $('#body table td, #body-po table td').mousedown(function(ev) {
        $('#context-menu').hide();
        $('#clicked-cell').val("");
        $('#body table td.edited-cell, #body-po table td.edited-cell').mouseup(function(ev) {
            if (ev.button == 2) {
               $('#clicked-cell').val(this.id);
               $('#context-menu').css({top: ev.pageY, left: ev.pageX}).show()
            }
        })
    });

    $('#context-menu').unbind('click');
    
    //Unhighlight ячейку
    $('#context-menu').click(function() {
        var data = $('#clicked-cell').val().split("-");
        $.ajax({
            url: "/spreadsheets/unhighlight/" + data[1] + '?cell=' + data[2],
            type: "get",
            context: document.body,
            success: function() {
                $('#context-menu').hide();
                $('#' + $('#clicked-cell').val()).removeClass('edited-cell');
                $('#' + $('#clicked-cell').val()).unbind('mouseup');
                jQuery.noticeAdd({text: 'Successfully unhighlighted.'})
            },
            error: function(XMLHttpRequest, textStatus, errorThrown) {
                $('#context-menu').hide();
                var text = "Error: " + XMLHttpRequest.status + " " + XMLHttpRequest.statusText
                jQuery.noticeAdd({text: text, type: "error", stayTime: 5000})
            },
            beforeSend: function() {
                $("#spinner-dialog").dialog("open");
            },
            complete: function() {
                $("#spinner-dialog").dialog("close");
            }
        });
    });
}

//  ОТправка данных для редактирования ячейки
function submit_update_cell() {
    var url = ""
    if ($('#order_confirmation_row_id').val() == "")
        url = "/spreadsheets/" + $('#cell_id').val();
    else
        url = "/spreadsheets/" + $('#order_confirmation_row_id').val() + "/order_confirmations/" + $('#cell_id').val();
    $.ajax({
        url: url,
        type: "put",
        data: $("#edit-cell-form").serialize(),
        context: document.body,
        success: function() {
            $("#edit-cell").dialog('close');
            var cell = $("#cell-" + $('#cell_id').val() + "-" + $('#cell_field').val());
            cell.html($('#cell_data').val());
            jQuery.noticeAdd({text: 'Successfully updated.'})
        },
        error: function(XMLHttpRequest, textStatus, errorThrown) {
            $("#edit-cell").dialog('close');
            var text = "Error: " + XMLHttpRequest.status + " " + XMLHttpRequest.statusText
            jQuery.noticeAdd({text: text, type: "error", stayTime: 5000})
        },
        beforeSend: function() {
            $("#spinner-dialog").dialog("open");
        },
        complete: function() {
            $("#spinner-dialog").dialog("close");
        }
    });
}

// Отправка данных для добавления полей
function submit_add_rows() {
    $.ajax({
        url: "/spreadsheets",
        type: "post",
        data: $("#add-rows-form").serialize(),
        context: document.body,
        success: function() {
            $("#add-rows").dialog('close');
            var text = "";
            if ($('#rows_count').val() == "1")
                text = '1 row successfully added.'
            else
                text = $('#rows_count').val() + ' rows successfully added.'
            jQuery.noticeAdd({text: text})
            scroll_to($('#body table').height());

        },
        error: function(XMLHttpRequest, textStatus, errorThrown) {
            $("#add-rows").dialog('close');
            var text = "Error: " + XMLHttpRequest.status + " " + XMLHttpRequest.statusText
            jQuery.noticeAdd({text: text, type: "error", stayTime: 5000})
        },
        beforeSend: function() {
            $("#spinner-dialog").dialog("open");
        },
        complete: function() {
            $("#spinner-dialog").dialog("close");
        }
    });
}

// Отправка данных для поиска
function submit_search() {
    $.ajax({
        url: "/spreadsheets?filter[business]=" + business,
        type: "get",
        data: $("#search-form").serialize(),
        context: document.body,
        success: function() {
            $("#search").dialog('close');
            jQuery.noticeAdd({text: "Search results"})
            scroll_top();
        },
        error: function(XMLHttpRequest, textStatus, errorThrown) {
            $("#search").dialog('close');
            var text = "Error: " + XMLHttpRequest.status + " " + XMLHttpRequest.statusText
            jQuery.noticeAdd({text: text, type: "error", stayTime: 5000})
        },
        beforeSend: function() {
            $("#spinner-dialog").dialog("open");
        },
        complete: function() {
            $("#spinner-dialog").dialog("close");
        }
    });
}

// Отправка данных для редактирования
function submit_port_of_loading() {
    $.ajax({
        url: "/spreadsheets/" + $('#cell_id').val(),
        type: "put",
        data: $("#edit-cell-form").serialize(),
        context: document.body,
        success: function() {
            $("#edit-port-of-loading-cell").dialog('close');
            var cell = $("#cell-" + $('#cell_id').val() + "-" + $('#cell_field').val());
            cell.html($('#cell_data').val());
            jQuery.noticeAdd({text: 'Successfully updated.'})
        },
        error: function(XMLHttpRequest, textStatus, errorThrown) {
            $("#edit-port-of-loading-cell").dialog('close');
            var text = "Error: " + XMLHttpRequest.status + " " + XMLHttpRequest.statusText
            jQuery.noticeAdd({text: text, type: "error", stayTime: 5000})
        },
        beforeSend: function() {
            $("#spinner-dialog").dialog("open");
        },
        complete: function() {
            $("#spinner-dialog").dialog("close");
        }
    });
}

// Отправка данных для редактирования
function submit_mixed_port() {
    $.ajax({
        url: "/spreadsheets/" + $('#cell_id').val(),
        type: "put",
        data: $("#edit-cell-form").serialize(),
        context: document.body,
        success: function() {
            $("#edit-mixed-port-cell").dialog('close');
            var cell = $("#cell-" + $('#cell_id').val() + "-" + $('#cell_field').val());
            cell.html($('#cell_data').val());
            jQuery.noticeAdd({text: 'Successfully updated.'})
        },
        error: function(XMLHttpRequest, textStatus, errorThrown) {
            $("#edit-mixed-port-cell").dialog('close');
            var text = "Error: " + XMLHttpRequest.status + " " + XMLHttpRequest.statusText
            jQuery.noticeAdd({text: text, type: "error", stayTime: 5000})
        },
        beforeSend: function() {
            $("#spinner-dialog").dialog("open");
        },
        complete: function() {
            $("#spinner-dialog").dialog("close");
        }
    });
}

// Добавление комментария
function submit_add_notes(){
    $.ajax({
        url: "/spreadsheets/add_notes/"+ $('#cell_id').val(),
        type: "put",
        data: $("#notes-add-form").serialize(),
        context: document.body,
        success: function() {
            $("#edit-notes-cell").dialog('close');
            jQuery.noticeAdd({text: 'Successfully updated.'})
        },
        error: function(XMLHttpRequest, textStatus, errorThrown) {
            $("#edit-notes-cell").dialog('close');
            var text = "Error: " + XMLHttpRequest.status + " " + XMLHttpRequest.statusText
            jQuery.noticeAdd({text: text, type: "error", stayTime: 5000})
        },
        beforeSend: function() {
            $("#spinner-dialog").dialog("open");
        },
        complete: function() {
            $("#spinner-dialog").dialog("close");
        }
    });
}

// фильтрация по цветам
function submit_color_button(color) {
    $.ajax({
        url: "/spreadsheets?filter[business]=" + business + "&filter[color]=" + color,
        type: "get",
        context: document.body,
        success: function() {
            jQuery.noticeAdd({text: "Filtered"})
            scroll_top();
        },
        error: function(XMLHttpRequest, textStatus, errorThrown) {
            var text = "Error: " + XMLHttpRequest.status + " " + XMLHttpRequest.statusText
            jQuery.noticeAdd({text: text, type: "error", stayTime: 5000})
        },
        beforeSend: function() {
            $("#spinner-dialog").dialog("open");
        },
        complete: function() {
            $("#spinner-dialog").dialog("close");
        }
    });
}

// Выключает фильтры
function reset_filter() {
    rewrite_filter_params("");
    $.ajax({
        url: "/spreadsheets?filter[business]=" + business,
        type: "get",
        context: document.body,
        success: function() {
            $("#filters-form input").val("");
            $("#filters").dialog('close');
            jQuery.noticeAdd({text: "Filters reseted"})
            scroll_top();
        },
        error: function(XMLHttpRequest, textStatus, errorThrown) {
            $("#filters").dialog('close');
            var text = "Error: " + XMLHttpRequest.status + " " + XMLHttpRequest.statusText
            jQuery.noticeAdd({text: text, type: "error", stayTime: 5000})
        },
        beforeSend: function() {
            $("#spinner-dialog").dialog("open");
        },
        complete: function() {
            $("#spinner-dialog").dialog("close");
        }
    });
}

// Очищает все поля для фильтров и поиска
function clear_params() {
    rewrite_filter_params("");
    $("#filters-form input").val("");
    $("#search-form input").val("");

    $('#head img').remove();
    $('#appendix img').remove();
    $('#po-field img').remove();

    sort_field = '';
    $('#po-field').append(' <img src="/images/sort_desc.png" alt="" />')
}

$(document).ready( function() {

    // Хак для ие. Выводит предупреждение о неппорживаемости некоторых функций
    // в ие
    if ($.browser.msie) {
        $("body").append('\
            <div id="no-supported" title="Your browser not supported.">\n\
                <p>\n\
                    <span class="access-alert"></span>\n\
                    Sorry, your browser is not fully supported. Please use\n\
                    <ul>\n\
                        <li><a href="http://www.mozilla.com">Mosilla Firefox</a> (recommended)</li>\n\
                        <li><a href="http://www.opera.com/download/">Opera</a></li>\n\
                        <li><a href="www.apple.com/safari/download/">Safari</a></li>\n\
                        <li><a href="www.google.com/chrome">Google Chrome</a></li>\n\
                    </ul>\n\
                </p>\n\
            </div>\n\
        ')

        $("#no-supported").dialog({
            autoOpen: true,
            width: 230,
            modal: true,
            resizable: false,
            buttons: {
                Close: function() {
                    $(this).dialog('close');
                }
            }
        });

        // Обновляет стили для нормального отображения данных в ие
        initformsie();
    }

    // Хак для оперы. Добавляет <br /> между телом таблицы и хеадером
    if ($.browser.opera) {
        $('#head').after('<br style="clear:both;width:1px;" />')
    }
    

    // Изначальное установление размеров в зависимости от размера рабочей
    // области браузера
    resize();

    // Таймер для обновления размера
    var resizeTimer = null;
    // Отслеживает изенения размера рабочей области браузера и запускает функция
    // изменения размеров элементов таблицы.
    $(window).resize( function() {
        if (resizeTimer) clearTimeout(resizeTimer);
        resizeTimer = setTimeout(function() {resize()}, 100);
    })

    // Прокручивание хеадера и нумерации в зависимости от прокрутки ячеек
    $('#body').scroll(function() {
        $("#head table").css( { "left": $('#body table').position().left } );
        $("#num table").css( { "top": $('#body table').position().top } );
        $("#body-po table").css( { "top": $('#body table').position().top } );
    });

    // По клику на диве открывает модальное окно для добавления новых строк
    // в таблицу
    $('#add-rows-button').click(function() {
        if (editable_fields.length > 0) {
            $('#add-rows').dialog('open');
            $('#rows_count').val("1");
            $('#rows_count').focus();
            $('#rows_count').select();
        }
    });

    // Создает модальное окно для редактирования данных ячейки
    $("#edit-cell").dialog({
        autoOpen: false,
        height: 117,
        width: 180,
        modal: true,
        resizable: false,
        buttons: {
            Cancel: function() {
                $(this).dialog('close');
            },
            'Update': function() {
                submit_update_cell()
            }
        },
        close: function() {
            if ($('#order_confirmation_row_id').val() == "")
                $("#body table .editing, #body-po table .editing").removeClass("editing");
            else
                $("#order-confirmation-table tbody td").removeClass("editing");
        }
    });

    // Создает модальное окно для добавления новых строк в таблицу
    $("#add-rows").dialog({
        autoOpen: false,
        height: 117,
        width: 180,
        modal: true,
        resizable: false,
        buttons: {
            Cancel: function() {
                    $(this).dialog('close');
            },
            'Add': function() {
                submit_add_rows();
            }
        }
    });

    //Создает модальное окно для фильтров
    $("#filters").dialog({
        autoOpen: false,
        height: 135,
        width: 335,
        modal: true,
        resizable: false,
        buttons: {
            Cancel: function() {
                    $(this).dialog('close');
            },
            'Filter': function() {
                $.ajax({
                    url: "/spreadsheets?filter[business]=" + business,
                    type: "get",
                    data: $("#filters-form").serialize(),
                    context: document.body,
                    success: function() {
                        $("#filters").dialog('close');
                        jQuery.noticeAdd({text: "Filtered"})
                        scroll_top();
                    },
                    error: function(XMLHttpRequest, textStatus, errorThrown) {
                        $("#filters").dialog('close');
                        var text = "Error: " + XMLHttpRequest.status + " " + XMLHttpRequest.statusText
                        jQuery.noticeAdd({text: text, type: "error", stayTime: 5000})
                    },
                    beforeSend: function() {
                        $("#spinner-dialog").dialog("open");
                    },
                    complete: function() {
                        $("#spinner-dialog").dialog("close");
                    }
                });
            },
            'Reset' : function() {
                reset_filter();
            }
        }
    });

    // Dialog with spinner
    $("#spinner-dialog").dialog({
        modal: true,
        autoOpen: false,
        resizable: false,
        draggable: false,
        closeOnEscape: false
    });

    // Access denied notification
    $("#access-denied").dialog({
        modal: true,
        autoOpen: false,
        resizable: false,
        draggable: false,
        width: 230,
        buttons: {
            Ok: function() {
                $(this).dialog('close');
            }
        },
        close: function() {
            $("#body table .editing, #body-po table .editing").removeClass("editing")
        }
    });

    // Создает модальное окно для редактирования данных ячеек типа даты.
    $("#edit-date-cell").dialog({
        autoOpen: false,
        height: 265,
        width: 270,
        modal: true,
        resizable: false,
        buttons: {
            Cancel: function() {
                $(this).dialog('close');
            },
            'Update': function() {
                var url = "";
                if ($('#order_confirmation_row_id').val() == "")
                    url = "/spreadsheets/" + $('#cell_id').val();
                else
                    url = "/spreadsheets/" + $('#order_confirmation_row_id').val() + "/order_confirmations/" + $('#cell_id').val();
                $.ajax({
                    url: url,
                    type: "put",
                    data: $("#edit-cell-form").serialize(),
                    context: document.body,
                    success: function() {
                        $("#edit-date-cell").dialog('close');
                        var cell;
                        if ($('#order_confirmation_row_id').val() == "")
                            cell = $("#body table #cell-" + $('#cell_id').val() + "-" + $('#cell_field').val());
                        else
                            cell = $("#order-confirmation-table #cell-" + $('#cell_id').val() + "-" + $('#cell_field').val());
                        cell.html($('#cell_data').val());
                        jQuery.noticeAdd({text: 'Successfully updated.'})
                    },
                    error: function(XMLHttpRequest, textStatus, errorThrown) {
                        $("#edit-date-cell").dialog('close');
                        var text = "Error: " + XMLHttpRequest.status + " " + XMLHttpRequest.statusText
                        jQuery.noticeAdd({text: text, type: "error", stayTime: 5000})
                    },
                    beforeSend: function() {
                        $("#spinner-dialog").dialog("open");
                    },
                    complete: function() {
                        $("#spinner-dialog").dialog("close");
                    }
                });
            },
            'Reset': function() {
                var url = "";
                if ($('#order_confirmation_row_id').val() == "")
                    url = "/spreadsheets/" + $('#cell_id').val();
                else
                    url = "/spreadsheets/" + $('#order_confirmation_row_id').val() + "/order_confirmations/" + $('#cell_id').val();
                $('#cell_data').val("");
                $.ajax({
                    url: url,
                    type: "put",
                    data: $("#edit-cell-form").serialize(),
                    context: document.body,
                    success: function() {
                        $("#edit-date-cell").dialog('close');
                        var cell;
                        if ($('#order_confirmation_row_id').val() == "")
                            cell = $("#body table #cell-" + $('#cell_id').val() + "-" + $('#cell_field').val());
                        else
                            cell = $("#order-confirmation-table #cell-" + $('#cell_id').val() + "-" + $('#cell_field').val());
                        cell.html($('#cell_data').val());
                        jQuery.noticeAdd({text: 'Successfully updated.'})
                    },
                    error: function(XMLHttpRequest, textStatus, errorThrown) {
                        $("#edit-date-cell").dialog('close');
                        var text = "Error: " + XMLHttpRequest.status + " " + XMLHttpRequest.statusText
                        jQuery.noticeAdd({text: text, type: "error", stayTime: 5000})
                    },
                    beforeSend: function() {
                        $("#spinner-dialog").dialog("open");
                    },
                    complete: function() {
                        $("#spinner-dialog").dialog("close");
                    }
                });
            }
        },
        close: function() {
            if ($('#order_confirmation_row_id').val() == "")
                $("#body table .editing").removeClass("editing")
            else
                $("#order-confirmation-table tbody td").removeClass("editing");
        }
    });

    var notes_buttons = {
        Cancel: function() {
            $("#edit-notes-cell").dialog('close');
        }
    };

    if (role) notes_buttons['Update'] = function() {
                $('#cell_data').val($('#cell_notes').val());
                $.ajax({
                    url: "/spreadsheets/" + $('#cell_id').val(),
                    type: "put",
                    data: $("#edit-cell-form").serialize(),
                    context: document.body,
                    success: function() {
                        $("#edit-notes-cell").dialog('close');
                        var cell = $("#cell-" + $('#cell_id').val() + "-" + $('#cell_field').val());
                        cell.html($('#cell_data').val());
                        jQuery.noticeAdd({text: 'Successfully updated.'})
                    },
                    error: function(XMLHttpRequest, textStatus, errorThrown) {
                        $("#edit-notes-cell").dialog('close');
                        var text = "Error: " + XMLHttpRequest.status + " " + XMLHttpRequest.statusText
                        jQuery.noticeAdd({text: text, type: "error", stayTime: 5000})
                    },
                    beforeSend: function() {
                        $("#spinner-dialog").dialog("open");
                    },
                    complete: function() {
                        $("#spinner-dialog").dialog("close");
                    }
                });
            }

    // Создает модальное окно для редактирования данных ячеек типа notes.
    $("#edit-notes-cell").dialog({
        autoOpen: false,
        height: 380,
        width: 550,
        modal: true,
        resizable: false,
        buttons: notes_buttons,
        close: function() {
            $("#body table .editing").removeClass("editing")
        }
    });

    // Создает модальное окно для редактирования данных ячеек типа port of loading.
    $("#edit-port-of-loading-cell").dialog({
        autoOpen: false,
        height: 120,
        width: 225,
        modal: true,
        resizable: false,
        buttons: {
            Cancel: function() {
                $(this).dialog('close');
            },
            'Reset': function() {
                $('#cell_data').val("");
                submit_port_of_loading();
            }
        },
        close: function() {
            $("#body table .editing").removeClass("editing")
        }
    });

    // Создает модальное окно для редактирования данных ячеек типа mixed port.
    $("#edit-mixed-port-cell").dialog({
        autoOpen: false,
        height: 120,
        width: 180,
        modal: true,
        resizable: false,
        buttons: {
            Cancel: function() {
                $(this).dialog('close');
            },
            'Reset': function() {
                $('#cell_data').val("");
                submit_mixed_port();
            }
        },
        close: function() {
            $("#body table .editing").removeClass("editing")
        }
    });

    // Окно лога
    $("#system-log").dialog({
        autoOpen: false,
        width: 600,
        modal: true,
        resizable: false,
        position: ['center', 20],
        buttons: {
            'Close': function() {
                $(this).dialog('close');
            },
            'Refresh' :  function() {
                $.ajax({
                    url: "/spreadsheets/log",
                    type: "get",
                    beforeSend: function() {
                        $("#spinner-dialog").dialog("open");
                    },
                    complete: function() {
                        $("#spinner-dialog").dialog("close");
                    }
                });
            }
        },
        open: function(event, ui) {
            $.ajax({
                url: "/spreadsheets/log",
                type: "get",
                beforeSend: function() {
                    $("#spinner-dialog").dialog("open");
                },
                complete: function() {
                    $("#spinner-dialog").dialog("close");
                }
            });
        }
    });

    // Попап окно order-confirmation
    $("#order-confirmation").dialog({
        autoOpen: false,
        width: 700,
        modal: true,
        resizable: false,
        buttons: {
        },
        open: function(event, ui) {
            $.ajax({
                url: "/spreadsheets/" + $('#order_confirmation_row_id').val() + "/order_confirmations",
                type: "get",
                beforeSend: function() {
                    $("#spinner-dialog").dialog("open");
                },
                complete: function() {
                    order_conformation_initializer();
                    $("#spinner-dialog").dialog("close");
                }
            });
        },
        close: function() {
            $("#body table .editing").removeClass("editing");
            $('#order_confirmation_row_id').val('');
        }
    });

    // Создает календарь для выбора промежутка времени. Используется для
    // фильтрования по полю ETA
    var eta_dates = $('#filter_eta_from, #filter_eta_to').datepicker({
        defaultDate: "+1w",
        changeMonth: true,
        showButtonPanel: true,
        onSelect: function(selectedDate) {
            var option = this.id == "filter_eta_from" ? "minDate" : "maxDate";
            var instance = $(this).data("datepicker");
            var date = $.datepicker.parseDate(
                instance.settings.dateFormat ||
                $.datepicker._defaults.dateFormat, selectedDate, instance.settings
            );
            eta_dates.not(this).datepicker("option", option, date);
        }
    });

    // Создает календарь для выбора промежутка времени. Используется для
    // фильтрования по полю ETD
    var etd_dates = $('#filter_etd_from, #filter_etd_to').datepicker({
        defaultDate: "+1w",
        changeMonth: true,
        showButtonPanel: true,
        onSelect: function(selectedDate) {
            var option = this.id == "filter_etd_from" ? "minDate" : "maxDate";
            var instance = $(this).data("datepicker");
            var date = $.datepicker.parseDate(
                instance.settings.dateFormat ||
                $.datepicker._defaults.dateFormat, selectedDate, instance.settings
            );
            etd_dates.not(this).datepicker("option", option, date);
        }
    });

    // Создает календарь для выбора промежутка времени. Используется для
    // фильтрования по полю Delivery Date
    var delivery_dates = $('#filter_delivery_date_from, #filter_delivery_date_to').datepicker({
        defaultDate: "+1w",
        changeMonth: true,
        showButtonPanel: true,
        onSelect: function(selectedDate) {
            var option = this.id == "filter_delivery_date_from" ? "minDate" : "maxDate";
            var instance = $(this).data("datepicker");
            var date = $.datepicker.parseDate(
                instance.settings.dateFormat ||
                $.datepicker._defaults.dateFormat, selectedDate, instance.settings
            );
            delivery_dates.not(this).datepicker("option", option, date);
        }
    });

    //Create inline datepicker
    $("#inline-datepicker").datepicker({
        defaultDate: 0,
        onSelect: function(selectedDate) {
            $('#cell_data').val(selectedDate);
        }
    });

    // Создает кнопку для открытия окна фильтров.
    $("#filter-button").button();

    // Создает кнопку выключения фильтров.
    $("#reset-filter-button").button();

    // Открывает окно фильтров
    $("#filter-button").click(function() {
        $('#filters').dialog('open');
    });

    // Очищает результаты фильтрования
    $("#reset-filter-button").click(function() {
        reset_filter();
    });

    // Создает кнопку для открытия окна поиска.
    $("#search-button").button();
    // Создает кнопку для очистки результатов поиска
    $("#reset-search-button").button();

    // Открывает окно поиска
    $("#search-button").click(function() {
        submit_search();
    });

    // Очищает результаты поиска.
    $("#reset-search-button").click(function() {
        $.ajax({
            url: "/spreadsheets?filter[business]=" + business,
            type: "get",
            context: document.body,
            success: function() {
                $("#search-form input").val("");
                $("#search").dialog('close');
                jQuery.noticeAdd({text: "Search reseted"})
                scroll_top();
            },
            error: function(XMLHttpRequest, textStatus, errorThrown) {
                $("#search").dialog('close');
                var text = "Error: " + XMLHttpRequest.status + " " + XMLHttpRequest.statusText
                jQuery.noticeAdd({text: text, type: "error", stayTime: 5000})
            },
            beforeSend: function() {
                $("#spinner-dialog").dialog("open");
            },
            complete: function() {
                $("#spinner-dialog").dialog("close");
            }
        });
    });

    // Открывает окно лога
    $('#system-log-link').click(function() {
        $("#system-log").dialog('open');
        return false;
    });

    // port of loading buttons
    $("#port-of-loading-buttonset").buttonset();
    $("#port-of-loading-buttonset input:radio").click(function() {
       $('#cell_data').val($('#port-of-loading-buttonset label[for|=' + this.id + '] span').html());
       submit_port_of_loading();
    });

    // Business names buttons
    $("#business-names-buttonset").buttonset();
    $("#business-names-buttonset input:radio").click(function() {
        clear_params();
        set_business("cent");
        var id = this.id;
        if ($('#business-names-buttonset label[for|=' + id + '] span').html() == "CTI")
            set_business("cti");

        $.ajax({
            url: "/spreadsheets?filter[business]=" + business,
            type: "get",
            context: document.body,
            success: function() {
                jQuery.noticeAdd({text: $('#business-names-buttonset label[for|=' + id + '] span').html()})
                scroll_top();
            },
            error: function(XMLHttpRequest, textStatus, errorThrown) {
                var text = "Error: " + XMLHttpRequest.status + " " + XMLHttpRequest.statusText
                jQuery.noticeAdd({text: text, type: "error", stayTime: 5000})
            },
            beforeSend: function() {
                $("#spinner-dialog").dialog("open");
            },
            complete: function() {
                $("#spinner-dialog").dialog("close");
            }
        });
    });

    // Color buttons
    $("#color-buttons button").button();
    // Click to red button
    $("#color-buttons button#red-button").click(function() {
        submit_color_button("red")
    });
    // Click to yellow button
    $("#color-buttons button#yellow-button").click(function() {
        submit_color_button("yellow")
    });

    // Mixed / Port buttons
    $("#mixed-port-buttonset").buttonset();
    $("#mixed-port-buttonset input:radio").click(function() {
       $('#cell_data').val($('#mixed-port-buttonset label[for|=' + this.id + '] span').html());
       submit_mixed_port();
    });

    // Блокировка окна notes
    $("#cell_notes").focus(function() {
        if (!role) $(this).attr('disabled', 'disabled');
    });

    // Add note button
    $("#notes-add-button").button();

    $("#notes-add-button").click(function() {
        $("#notes_add").val();
    });
    
    // Инициализирует основные функции для ячеек и строк.
    //  - Подсветка ячеек
    //  - Обработка двойного клика на ячейку
    //  - Установка обработчика включения/выключения видимости строки
    //  - Создания кнопок вулючения/выключения видиости строк
    // В качестве параметрa передается id строки. Чтобы переформировать все
    // выключатели используется параметр 'all' в качестве id.
    initializer('all');

});

// Хак для ие. Добавляет в пустые ячейки пробелы (иначе ячейки не отображаются),
// высталвляет высоту для полей и если поле из-за контента по высоте больше 25
// пикселей, то растягивает высоту колонки нумирации.
function initformsie() {

    if ($.browser.msie) {

        $("#body table td, #body-po table td").each(function() {
            if (jQuery.trim($(this).html()) == "") { $(this).html(" ") }
        });

        $("#num table tr").css({height: 25})

        $("#body table tr, #body-po table tr").each(function() {
            $(this).css({height: 25})
            if ($(this).height() > 25) {
                $('#rownum_' + this.id.split("_")[2]).css({height: $(this).height()})
                $('#body-po_row_' + this.id.split("_")[2]).css({height: $(this).height()})
            }
        })

        $("#num table").css({width: 111})

        $("#body-po-table").css({width:101})

    }
}


function initializer(row_id) {

    // Подсвечивает ячейки при наведении на них курсора
    $("#body table td, #body-po table td, #order-confirmation-table tbody td").hover(
        function() {
          $(this).addClass("highlight-cell");

          //Рисует хелперы, показывающие местоположение выбранной ячейки
          var top = $(this).offset().top;
          var left = $(this).offset().left;
          var width = $(this).outerWidth(true);
          var height = $(this).outerHeight(true);
          // Высчитывает, чтобы хелперы не вылазили за пределы видимой области.
          var correction = 0;
          if (top < min_top) {
              correction = min_top - top;
              top = top + correction;
              height = height - correction;
          }

          if (left < min_left) {
              correction = min_left - left;
              if (!$(this).hasClass("body-po")) {
                  left = left + correction;
                  width = width - correction;
              }
          }

          if ((top + height) > max_top) {
              correction = (top + height) - max_top;
              height = height - correction;
          }

          if ((left + width) > max_left) {
              correction = (left + width) - max_left;
              width = width - correction;
          }

          // Рисует хелперы вокруг левого и верхнего обозначений позиции ячейки.
          $('#left-helper').show().css({
              top: top - 1,
              height: height - 3
          });
          $('#top-helper').show().css({
              left: left - 1,
              top: actions_height,
              width: width - 3
          });

          // Рисует хелпер вокруг ячейки. Пока не используется.

//          $('#main-left-helper').show().css({
//              left: left - 1,
//              height: height + 1,
//              top: top - 1,
//              width: 1
//          });
//          $('#main-right-helper').show().css({
//              left: left + width - 1,
//              height: height + 1,
//              top: top - 1,
//              width: 1
//          });
//          $('#main-top-helper').show().css({
//              left: left - 1,
//              width: width,
//              top: top - 1,
//              height: 1
//          });
//          $('#main-bottom-helper').show().css({
//              left: left - 1,
//              width: width,
//              top: top + height - 1,
//              height: 1
//          });
        },
        function() {
          $(this).removeClass("highlight-cell");
          $('.helpers, .main-helpers').hide();
        }
    );

    // Устанавливает ивент на двойное нажатие на ячейку. Если пользователь может
    // редактировать данное поле, то открывает модальное окно для редактирования.
    //  - Подсвечивает редактируемую ячейку
    //  - Открывает откно редактирования
    //  - Из id ячейки получает id RowSpreadsheet который будет редактироваться
    //    и имя поля, которое редактируется.
    //  - Устанавливает значния для скрытых полей в окне рактирования
    //  - Забирает данные из ячейки
    // Если пользователь не может редактировать данное поле, выводить
    // предупреждение.
    $('#body table td, #body-po table td').dblclick(function() {
        var data = this.id.split("-");
        $(this).addClass('editing');
        if (jQuery.inArray(data[2], editable_fields) < 0)
            $('#access-denied').dialog('open');
        else if ($(this).hasClass('date')) {
            $('#edit-date-cell').dialog('open');
            $('#edit-date-cell').dialog({defaultDate: 0});
            $('#cell_id').val(data[1]);
            $('#cell_field').val(data[2]);
            $('#cell_data').val(formatDate(new Date()));
        } else if ($(this).hasClass('port-of-loading')) {
            $("#port-of-loading-buttonset input:radio").removeAttr('checked');
            $("#" + $(this).html().toLowerCase() + "-radio").attr('checked', 'checked');
            $("#port-of-loading-buttonset").buttonset();
            $('#edit-port-of-loading-cell').dialog('open');
            $('#cell_id').val(data[1]);
            $('#cell_field').val(data[2]);
            $('#cell_data').val($(this).html());
        } else if ($(this).hasClass('mixed-port')) {
            $("#mixed-port-buttonset input:radio").removeAttr('checked');
            $("#" + $(this).html().toLowerCase() + "-radio").attr('checked', 'checked');
            $("#mixed-port-buttonset").buttonset();
            $('#edit-mixed-port-cell').dialog('open');
            $('#cell_id').val(data[1]);
            $('#cell_field').val(data[2]);
            $('#cell_data').val($(this).html());
        } else if ($(this).hasClass('notes')) {
            $('#edit-notes-cell').dialog('open');
            $('#edit-notes-cell').dialog({defaultDate: 0});
            $('#cell_id').val(data[1]);
            $('#cell_field').val(data[2]);
            $("#notes_add").val("");
            if ($.browser.msie) {
                $('#cell_data').val(jQuery.trim($(this).html()));
                $('#cell_notes').val(jQuery.trim($(this).html()));
            } else {
                $('#cell_data').val($(this).html());
                $('#cell_notes').val($(this).html());
            }
            $('#cell_notes').focus();
            $('#cell_notes').select();
            
            $('#notes_add').focus();
            $('#notes_add').select();
        } else if ($(this).hasClass("order-confirmation")) {
            $('#order_confirmation_row_id').val(data[1]);
            $('#order-confirmation').html("");
            $('#order-confirmation').dialog('open');
        } else {
            $('#cell_data').val('');
            $('#edit-cell').dialog('open');
            $('#cell_id').val(data[1]);
            $('#cell_field').val(data[2]);
            if ($.browser.msie)
                $('#cell_data').val(jQuery.trim($(this).html()));
            else
                $('#cell_data').val($(this).html());
            $('#cell_data').focus();
            $('#cell_data').select();
        }
    });

    // Disable text selection
    if ($.browser.mozilla) {
        $('#body, #body-po, #order-confirmation-table').each(function() {
            $(this).css({ 'MozUserSelect': 'none' });
        });
    } else if ($.browser.msie) {
        $('#body, #body-po, #order-confirmation-table').each(function() {
            $(this).bind('selectstart.disableTextSelect', function() { return false; });
        });
    } else {
        $('#body, #body-po, #order-confirmation-table').each(function() {
            $(this).bind('mousedown.disableTextSelect', function() { return false; });
        });
    }

    // Для поля notes добавляет всплывающую подсказку
    $('#body table td.tipsed').tipsy({
        gravity: $.fn.tipsy.autoNS,
        fade: true,
        html: true,
        title: function() {
            if ($(this).html().trim() != '')
                return $(this).text().replace(/\n/ig, "<br />");
            else
                return null;
        }
    });

    change_visible_row(row_id);

    visible_row(row_id);

}

function order_conformation_initializer() {
    // Устанавливает ивент на двойное нажатие на ячейку order confirmation
    $('#order-confirmation-table tbody td').dblclick(function() {
        var data = this.id.split("-");
        $(this).addClass('editing');
        if ($(this).hasClass('date')) {
            $('#edit-date-cell').dialog('open');
            $('#edit-date-cell').dialog({defaultDate: 0});
            $('#cell_id').val(data[1]);
            $('#cell_field').val(data[2]);
            $('#cell_data').val(formatDate(new Date()));
        } else {
            $('#cell_data').val('');
            $('#edit-cell').dialog('open');
            $('#cell_id').val(data[1]);
            $('#cell_field').val(data[2]);
            if ($.browser.msie)
                $('#cell_data').val(jQuery.trim($(this).html()));
            else
                $('#cell_data').val($(this).html());
            $('#cell_data').focus();
            $('#cell_data').select();
        }
    });

    // Для полей .tipsed добавляет всплывающую подсказку
    $('#order-confirmation table td.tipsed').tipsy({
        gravity: $.fn.tipsy.autoNS,
        fade: true,
        html: true,
        title: function() {
            if ($(this).html().trim() != '')
                return $(this).text().replace(/\n/ig, "<br />");
            else
                return null;
        }
    });

    // Disable text selection
    if ($.browser.mozilla) {
        $('#order-confirmation-table').each(function() {
            $(this).css({ 'MozUserSelect': 'none' });
        });
    } else if ($.browser.msie) {
        $('#order-confirmation-table').each(function() {
            $(this).bind('selectstart.disableTextSelect', function() { return false; });
        });
    } else {
        $('#order-confirmation-table').each(function() {
            $(this).bind('mousedown.disableTextSelect', function() { return false; });
        });
    }

    // Подсвечивает ячейки при наведении на них курсора
    $("#order-confirmation-table tbody td").hover(
        function() {
          $(this).addClass("highlight-cell");
        },
        function() {
          $(this).removeClass("highlight-cell");
        }
    );

}
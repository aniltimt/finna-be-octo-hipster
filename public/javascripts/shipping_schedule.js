$(document).ready(function () {

    var container = $('#schedule');
    var data = container.data('schedule');
    var settings = container.data('settings');
    var per_page = 15;
    var pages;
 	var page_change = false;
    var filter = false;
    var after_filter = false;

    container.attr('data-settings','')
    container.attr('data-schedule','')
    paginationSetup = function () {
        pages = data.length / per_page;
        if (data.length % per_page > 0) {
            pages += 1
        }
        $('#schedule').after('<div id="schedule_pagination"></div>');
        pagination = $('#schedule_pagination');

        for (var i = 1; i <= pages; i++) {
            pagination.append('<a href="#' + i + '">' + i + '</a>');
        }

        $(window).on('hashchange', function () {
            container.data('handsontable').loadData(paginateData())
        })

    };

    currentPage = function () {
        return parseInt(window.location.hash.replace('#', ''), 10) || 1;
    };

    paginateData = function () {
        var page = currentPage()
            , row = (page - 1) * per_page
            , count = page * per_page
            , part = [];

        for (; row < count; row++) {
            part.push(data[row]);
        }

        return part;
    };

    paginationSetup();
    
    /******* FUNCTIONS TO USE IN RENDERER ************/
   
   /*** ROW FUNCTIONS ***/
   
   
   	//Get index of first row on the page.
	getFirstRow=function(){
		return (currentPage()-1)*per_page;
	}
	
	//No empty rows coloured.
	checkEmptyRow=function(row){
	    var $current_row = $("#schedule tr:eq("+row+")");
	    var row_length = $current_row.find('td').length;
	    var empty_cells = $current_row.find('td:empty').length;
	    if((row_length == empty_cells) && empty_cells != 0)
	    	return true;
	    else
	    	return false;
	}
	
	/*** HIGHLIGHT FUNCTIONS ***/
	
	//Highlight row.
	highlightRow=function(row, colour){
    	$("#schedule tr:eq("+row+") td").css({ background: colour});
	}

	/** Date functions for etaHighlighter **/
	
	//Returns date which can be used in comparisons.
	getCalculableDate=function(td){
		if(td == null) return;
	    schedule_date = td.substring(0,10);
	    schedule_year = schedule_date.substring(6,10);
	    //months in JS are numered from 0 to 11
	    schedule_month = schedule_date.substring(3,5);
	    if(schedule_month != 0)
	        schedule_month -= 1;
	    schedule_day = schedule_date.substring(0,2);
	    calculable_date = new Date(schedule_year, schedule_month, schedule_day);
	    return calculable_date;
	}
	//Adds days to the date.
	addDaysToDate=function(date, days){
	    return new Date(date.setDate(date.getDate()+days));
	}
	
	/** Renderer variables **/
	
	//Row indexer for renderer.
	var rendererIndex = getFirstRow();
	//Pre-loop settings: set prev_row to 0.
	prev_row = 0;
	//Pre-loop settings: get current page.
	var current_page = currentPage();
	
	/*** RENDERER FUNCTIONS***/
	
	//Colour cell with colour based on role of updater.
	colourCell=function(td){
		$(td).css({background: data[rendererIndex]['colour']});
	}
	
	//Make link from path and title.
	makeLink=function(td, path, title){
		td.innerHTML='<a href="'+path+'">'+title+'</a>';
	}
	
	//Highlight eta_to_customer.
	etaHighlighter=function(td){
		if(data[rendererIndex]['requested_delivery'] != null) {
			var eta_date = getCalculableDate(data[rendererIndex]['eta_to_customer']);
			var rd_date = getCalculableDate(data[rendererIndex]['requested_delivery']);
			rd_date = addDaysToDate(rd_date, 7);
			if(eta_date > rd_date && rd_date.getFullYear() != 1900 && rd_date.getFullYear() != NaN) {
				$(td).css({ background: 'red' });
			}
			else $(td).css({ background: data[rendererIndex]['colour']})
		}
	}
	
	customRenderer=function (instance, td, row, col, prop, value, cellProperties) {
		//Page changing detector.
		if(current_page != currentPage()) {
			//Update current page data holder.
			current_page = currentPage();
			//Reload data.
			container.data('handsontable').loadData(paginateData());
			//Set renderer.
			rendererIndex = getFirstRow();
			//page_change = true;
		}
		//Apply changes.
		Handsontable.TextCell.renderer.apply(this, arguments);
		//Detect row change and use it for changing rendererIndex.
		if(row > prev_row) {
			if(rendererIndex <= row) //after filter or page_change index could be like 15...
				rendererIndex = row;
			else { //...so just pass it here.
				if(rendererIndex+1 >= currentPage()*per_page || rendererIndex+1 >= data.length)
					rendererIndex = getFirstRow();
				else
					rendererIndex++;
			}
		}
		//End of page, so go back to first row.
		else if(row == 0) {
			if(prev_row == per_page-1) {
				rendererIndex = getFirstRow();
			}		
		}
		// Rpws with data.
		if(!checkEmptyRow(row+1) && rendererIndex < data.length) {
			{
				//no filter no problem.
				if(!filter && !after_filter) {
					//Colour cells.
					colourCell(td);
				}
				//Filter present
				else if(filter) {
					//Data accessible.
					if(rendererIndex < data.length)
						//Colour cells as normally you would do.
						colourCell(td);
					else {
						//End of data, so end of filter
						filter = false;
						//However,after fitler cleaning is needed.
						after_filter = true;

					}//onClick="return false;"
				}
				//Make links - edit order.
				if(prop == 'edit_order_link' && value != null) {
					makeLink(td, value, 'Edit order');
			  	}
			  	//Make links - edit production order
			  	if(prop == 'edit_production_order_link' && value != null) {
					makeLink(td, value, 'Edit production order')
				}
				//Highlight Eta_to_Customer older than requested_delivery + 7 days
				if(prop == 'eta_to_customer') {
					etaHighlighter(td);
				}
			}
		}
		//Renderer index will be greater than data.length so special fitler is needed.
		if(after_filter){
			if(rendererIndex >= currentPage()*per_page){
				//Turn off filter, whole page is rendered now.
				after_filter = false;
				//go back to the beginning of data.
				rendererIndex = getFirstRow();
			}
		}
		//end of page or end of data
		else if(rendererIndex >= currentPage()*per_page) {
			//go back to the beginning of data.
			rendererIndex = getFirstRow();
			//if(page_change)page_change=false; Might use it in the ETA Highlighter rework.
		}
		//Set prev_row to use with comparisons on the next render(row change detection)
		prev_row = row;
	}

    container.handsontable({
        columnSorting: true,
        colHeaders: settings.colHeaders,
        colWidths: settings.colWidths,
        columns: settings.columns,
        data: paginateData(),
        minSpareRows: 0,
        
        beforeChange: function(change, source) {
            dataIndex = change[0][0] + ((currentPage() - 1) * per_page);
            return (dataIndex < data.length);
        },
        afterChange: function (change, source) {
            if (source != 'loadData') {
                dataIndex = change[0][0] + ((currentPage() - 1) * per_page);
                if (dataIndex < data.length) {
                    var orderId = data[dataIndex]['id'];
                    $.ajax({
                        type: 'post',
                        url: '/admin/shipping_schedule/update/' + orderId,
                        data: {order_id: orderId, field: change[0][1], value: change[0][3]}
                    })
                }

            }
        },
       cells: function (row, col, prop) {
      		this.renderer = customRenderer;
  		} 
    });


    $('.add_date_picker input.pickdate').datepicker({
        dateFormat: 'dd-mm-yy',
        defaultDate: -30
    });

    $('.add_date_picker button').click(function (event) {
        event.preventDefault()
        $('.hasDatepicker', $(this).parent()).val('')
    });


    $('#filter_form').submit(function (event) {
        event.preventDefault()

        var serializedForm = $(this).serialize()

        $.ajax({
            type: 'get',
            url: $(this).attr('action'),
            data: $(this).serialize(),
            beforeSend: function (xhr, settings) {
                xhr.setRequestHeader("Accept", "application/json")
            },
            success: function (response) {
                data = response;
                container.data('handsontable').loadData(paginateData())
                downloadLink = $('#download')
                var root = downloadLink.attr('href').split('?')[0]
                downloadLink.attr('href', root + '?' + serializedForm)
            }
        })
        data = container.data('schedule');
    	rendererIndex = getFirstRow();
    	filter=true;
    });

    $('#download').click(function (event) {
        var filters = $('#filter_form').serialize()
        window.location = $(this).attr('href') + filters

    });
    
});
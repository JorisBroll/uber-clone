Tools = {
	fastAjax: function(path, args, done, method) {
		if(typeof(method)==='undefined')
			method
        $.ajax({
            url: path,
            type: method,
            dataType: "json",
            data: args
        }).done(done);
	}
}
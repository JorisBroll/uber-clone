Tools = {
	fastAjax: function(path, args, done) {
        $.ajax({
            url: path,
            type: 'GET',
            dataType: "json",
            data: args
        }).done(done);
	}
}
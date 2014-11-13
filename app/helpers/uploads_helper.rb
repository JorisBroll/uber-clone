module UploadsHelper
	def save_photo(photo, name)
		if photo
			name = name+File.extname(photo.original_filename)
		    directory = "app/assets/images/photos"
		    path = File.join(directory, name)
		    save_upload(path, photo)
	    	return name
		else
			return false
	    end
	end

	def save_upload(path, file)
		File.open(path, "wb") { |f| f.write(file.read) }
	end
end

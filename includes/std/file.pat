#pragma once

/*!
	The File library allows reading and writing from/to external files using 
	a C-like File IO API.

	**These functions are considered dangerous and require the user to manually permit them**
*/

namespace std::file {

	/**
        A handle representing a file that has been opened
    */
	using Handle = s32;
	
	/**
        The mode to open a file in.
		Read opens the file in read-only mode
		Write opens the file in read and write mode
		Create creates a new file if it doesn't exist and overwrites an existing file
    */
	enum Mode : u8 {
		Read = 1,
		Write = 2,
		Create = 3
	};


	/**
        Opens a file
		@param path The path to the file to open
		@param mode File open mode
		@return Handle to the newly opened file
    */
	fn open(str path, Mode mode) {
		return builtin::std::file::open(path, u32(mode));
	};

	/**
        Closes a file handle that has been opened previously
		@param handle The handle to close
    */
	fn close(Handle handle) {
		builtin::std::file::close(handle);
	};

	
	/**
        Reads the content of a file into a string
		@param handle The file handle to read from
		@param size Number of bytes to read
		@return String containing the read data
    */
	fn read(Handle handle, u64 size) {
		return builtin::std::file::read(handle, size);
	};

	/**
        Writes the content of a string into a file
		@param handle The file handle to write to
		@param data String or Pattern to write to the file
    */
	fn write(Handle handle, auto data) {
		builtin::std::file::write(handle, data);
	};

	/**
        Sets the current cursor position in the given file handle
		@param handle The file handle to set the cursor position in
		@param offset The offset to move the cursor to
    */
	fn seek(Handle handle, u64 offset) {
		builtin::std::file::seek(handle, offset);
	};


	/**
		Queries the size of a file
		@param handle The handle of the file to get the size of
		@return The file's size
	*/
	fn size(Handle handle) {
		return builtin::std::file::size(handle);
	};

	/**
		Resizes a file 
		@param handle The handle of the file to resize
	*/
	fn resize(Handle handle, u64 size) {
		builtin::std::file::resize(handle, size);
	};

	/** 
		Flushes changes made to a file to disk
		@param handle The handle of the file to flush
	*/
	fn flush(Handle handle) {
		builtin::std::file::remove(handle);
	};


	/**
		Deletes a file from disk. This will also automatically close this file
		@param handle The handle of the file to delete
	*/
	fn remove(Handle handle) {
		builtin::std::file::remove(handle);
	};

}

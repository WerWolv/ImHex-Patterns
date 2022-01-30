#pragma once

namespace std::file {

	using Handle = s32;
	
	enum Mode : u8 {
		Read = 1,
		Write = 2,
		Create = 3
	};


	fn open(str path, Mode mode) {
		return builtin::std::file::open(path, mode);
	};

	fn close(Handle handle) {
		builtin::std::file::close(handle);
	};

	
	fn read(Handle handle, u64 size) {
		return builtin::std::file::read(handle, size);
	};

	fn write(Handle handle, str data) {
		return builtin::std::file::write(handle, data);
	};


	fn size(Handle handle) {
		return builtin::std::file::size(handle);
	};

	fn resize(Handle handle, u64 size) {
		builtin::std::file::resize(handle, size);
	};

	fn flush(Handle handle) {
		builtin::std::file::remove(handle);
	};


	fn remove(Handle handle) {
		builtin::std::file::remove(handle);
	};

}

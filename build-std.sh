#!/bin/bash
if [[ "$TARGET" = "powerpc64le-unknown-linux-musl" ]]
then
	cargo install xargo
	cargo new --lib custom-std
	cd custom-std
	cp /tmp/Xargo.toml .
	rustc -Z unstable-options --print target-spec-json --target $TARGET | tee "$TARGET.json"
	RUSTFLAGS="-L/usr/local/musl/$TARGET/lib -L/usr/local/musl/lib/gcc/$TARGET/9.2.0/" xargo build --target $TARGET
	HOST=$(rustc -Vv | grep 'host:' | awk '{print $2}')
	cp -r /root/.xargo/lib/rustlib/$TARGET /root/.rustup/toolchains/$TOOLCHAIN-$HOST/lib/rustlib/
	mkdir /root/.rustup/toolchains/$TOOLCHAIN-$HOST/lib/rustlib/$TARGET/lib/self-contained
	cp /usr/local/musl/$TARGET/lib/*.o /root/.rustup/toolchains/$TOOLCHAIN-$HOST/lib/rustlib/$TARGET/lib/self-contained/
	cp /usr/local/musl/lib/gcc/$TARGET/9.2.0/c*.o /root/.rustup/toolchains/$TOOLCHAIN-$HOST/lib/rustlib/$TARGET/lib/self-contained/
	cd ..
	rm -rf /root/.xargo /root/.cargo/registry /root/.cargo/git custom-std

	# compile libunwind
	cargo run --manifest-path /tmp/compile-libunwind/Cargo.toml -- --target "$TARGET" /root/.rustup/toolchains/$TOOLCHAIN-$HOST/lib/rustlib/src/rust/src/llvm-project/libunwind out
	cp out/libunwind*.a /root/.rustup/toolchains/$TOOLCHAIN-$HOST/lib/rustlib/$TARGET/lib/
	rm -rf out /tmp/compile-libunwind
fi

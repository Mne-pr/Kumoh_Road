package com.example.kumoh_road

import io.flutter.embedding.android.FlutterActivity

import android.os.Bundle
// [import android.os.Bundle], [override fun onCreate..] : naver map api 이슈 해결위한 추가
// https://note11.dev/flutter_naver_map/start/initial_setting

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        intent.putExtra("background_mode", "transparent")
        super.onCreate(savedInstanceState)
    }
}

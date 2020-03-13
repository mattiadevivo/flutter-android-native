package com.came.flutter_integration;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.widget.Button;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.embedding.engine.dart.DartExecutor;


public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // To warm up a FlutterEngine, you must execute a Dart entrypoint. Keep in mind that the
        // moment executeDartEntrypoint() is invoked, your Dart entrypoint method begins executing.
        // If your Dart entrypoint invokes runApp() to run a Flutter app, then your Flutter app
        // behaves as if it were running in a window of zero size until this FlutterEngine is
        // attached to a FlutterActivity, FlutterFragment, or FlutterView. Make sure that your
        // app behaves appropriately between the time you warm it up and the time you display
        // Flutter content.
        // Instantiate a FlutterEngine.
        FlutterEngine flutterEngine = new FlutterEngine(this);
        // Start executing Dart code to pre-warm the FlutterEngine.
        flutterEngine.getDartExecutor().executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
        );
        // Cache the FlutterEngine to be used by FlutterActivity.
        FlutterEngineCache
                .getInstance()
                .put("my_engine_id", flutterEngine);

        Button clickMeBtn = this.findViewById(R.id.click_me_button);
        // Without cached Flutter Engine
        /*clickMeBtn.setOnClickListener(v -> this.
                startActivity(
                        FlutterActivity.createDefaultIntent(this))
        );*/

        // With cached Flutter Engine
        clickMeBtn.setOnClickListener(v -> this.startActivity(
                FlutterActivity
                        .withCachedEngine("my_engine_id")
                        .build(this)
        ));
    }
}

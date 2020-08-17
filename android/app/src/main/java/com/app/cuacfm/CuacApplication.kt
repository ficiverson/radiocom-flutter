package com.app.cuacfm

import android.app.Activity
import android.content.Context
import androidx.annotation.CallSuper
import androidx.multidex.MultiDex
import androidx.multidex.MultiDexApplication
import io.flutter.view.FlutterMain


class CuacApplication : MultiDexApplication() {

    private var mCurrentActivity: Activity? = null

    @CallSuper
    override fun attachBaseContext(context: Context) {
        super.attachBaseContext(context)
        MultiDex.install(this)
    }

    fun getCurrentActivity(): Activity? {
        return this.mCurrentActivity
    }

    fun setCurrentActivity(mCurrentActivity: Activity) {
        this.mCurrentActivity = mCurrentActivity
    }

}
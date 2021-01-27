package io.rong.flutter.imlib.ext;

import android.os.Parcel;

import io.rong.imlib.model.MessageContent;

public class RCCustomMessage extends MessageContent {
    @Override
    public byte[] encode() {
        return new byte[0];
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel parcel, int i) {

    }
}

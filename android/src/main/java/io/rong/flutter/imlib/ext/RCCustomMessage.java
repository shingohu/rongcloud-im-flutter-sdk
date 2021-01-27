package io.rong.flutter.imlib.ext;

import android.os.Parcel;

import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import io.rong.common.ParcelUtils;
import io.rong.imlib.MessageTag;
import io.rong.imlib.model.MentionedInfo;
import io.rong.imlib.model.MessageContent;
import io.rong.imlib.model.UserInfo;

/**
 * Created by Beyond on 2016/12/5.
 */

@MessageTag(value = "custom", flag = MessageTag.ISCOUNTED | MessageTag.ISPERSISTED)
public class RCCustomMessage extends MessageContent {
    private final static String TAG = "RCCustomMessage";

    protected String type;
    protected Map data;

    /**
     * 将本地消息对象序列化为消息数据。
     *
     * @return 消息数据。
     */
    @Override
    public byte[] encode() {

        JSONObject jsonObj = new JSONObject();
        try {
            if (getType() != null) {
                jsonObj.put("type", getType());
            }

            if (getJSONUserInfo() != null)
                jsonObj.putOpt("user", getJSONUserInfo());

            if (getData() != null) {
                jsonObj.putOpt("data", new JSONObject(getData()));
            }


            if (getJsonMentionInfo() != null) {
                jsonObj.putOpt("mentionedInfo", getJsonMentionInfo());
            }
        } catch (JSONException e) {
            Log.e(TAG, "JSONException " + e.getMessage());
        }

        try {
            return jsonObj.toString().getBytes("UTF-8");
        } catch (UnsupportedEncodingException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return null;
    }


    public RCCustomMessage() {

    }


    public RCCustomMessage(byte[] data) {
        String jsonStr = null;
        try {
            jsonStr = new String(data, "UTF-8");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }

        try {
            JSONObject jsonObj = new JSONObject(jsonStr);

            if (jsonObj.has("type"))
                setType(jsonObj.optString("type"));
            if (jsonObj.has("data")) {
                setData(getMapForJson(jsonObj.optJSONObject("data").toString()));
            }

            if (jsonObj.has("user")) {
                setUserInfo(parseJsonToUserInfo(jsonObj.getJSONObject("user")));
            }

            if (jsonObj.has("mentionedInfo")) {
                setMentionedInfo(parseJsonToMentionInfo(jsonObj.getJSONObject("mentionedInfo")));
            }
        } catch (JSONException e) {
            Log.e(TAG, "JSONException " + e.getMessage());
        }

    }

    /**
     * 描述了包含在 Parcelable 对象排列信息中的特殊对象的类型。
     *
     * @return 一个标志位，表明Parcelable对象特殊对象类型集合的排列。
     */
    public int describeContents() {
        return 0;
    }

    /**
     * 将类的数据写入外部提供的 Parcel 中。
     *
     * @param dest  对象被写入的 Parcel。
     * @param flags 对象如何被写入的附加标志，可能是 0 或 PARCELABLE_WRITE_RETURN_VALUE。
     */
    @Override
    public void writeToParcel(Parcel dest, int flags) {
        ParcelUtils.writeToParcel(dest, getType());
        ParcelUtils.writeToParcel(dest, getData());
        ParcelUtils.writeToParcel(dest, getUserInfo());
        ParcelUtils.writeToParcel(dest, getMentionedInfo());
    }

    /**
     * 构造函数。
     *
     * @param in 初始化传入的 Parcel。
     */
    public RCCustomMessage(Parcel in) {
        setType(ParcelUtils.readFromParcel(in));
        setData(ParcelUtils.readMapFromParcel(in));
        setUserInfo(ParcelUtils.readFromParcel(in, UserInfo.class));
        setMentionedInfo(ParcelUtils.readFromParcel(in, MentionedInfo.class));
    }

    /**
     * 读取接口，目的是要从Parcel中构造一个实现了Parcelable的类的实例处理。
     */
    public static final Creator<RCCustomMessage> CREATOR = new Creator<RCCustomMessage>() {

        @Override
        public RCCustomMessage createFromParcel(Parcel source) {
            return new RCCustomMessage(source);
        }

        @Override
        public RCCustomMessage[] newArray(int size) {
            return new RCCustomMessage[size];
        }
    };


    public void setType(String type) {
        this.type = type;
    }

    public String getType() {
        return type;
    }

    public void setData(Map data) {
        this.data = data;
    }

    public Map getData() {
        return data;
    }

    /**
     * Json 转成 Map<>
     *
     * @param jsonStr
     * @return
     */
    public static Map<String, Object> getMapForJson(String jsonStr) {
        JSONObject jsonObject;
        try {
            jsonObject = new JSONObject(jsonStr);
            Iterator<String> keyIter = jsonObject.keys();
            String key;
            Object value;
            Map<String, Object> valueMap = new HashMap<String, Object>();
            while (keyIter.hasNext()) {
                key = keyIter.next();
                value = jsonObject.get(key);
                valueMap.put(key, value);
            }
            return valueMap;
        } catch (Exception e) {
            // TODO: handle exception
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<String> getSearchableWord() {
        List<String> words = new ArrayList<>();
        words.add(type);
        return words;
    }
}

package c.o.a.e;

import android.os.Handler;
import android.os.Message;
//                   'c/o/a/e/z0',  # hander
public class PDM extends Handler {
    public PDM() {

    }
    @Override
    public void handleMessage(Message message) {
        int r0 = message.what;
        lh.ActWv(r0);
    }
}


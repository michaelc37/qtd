module main;

/+
import qt.gui.QApplication;
import qt.core.QCoreApplication;
import qt.gui.QDialogButtonBox;
+/
import tango.io.Stdout;

extern(C) void* qtd_test_Object();
extern(C) void qtd_test_delete_Object(void* obj);

import qt.core.QObject;
import qt.core.QCryptographicHash;
import qt.core.QFSFileEngine;
import qt.QtdObject;


void main()
{
    //auto nativeId = qtd_test_Object();    
    scope obj = new QCryptographicHash(QCryptographicHash_Algorithm.Md5);
    obj.__nativeOwnership = true;
    qtd_test_delete_Object(obj.__nativeId);
    //Stdout(obj).newline;
}

/+
void main(char[][] args)
{
    /+
    scope app = new QCoreApplication(args);
    app.aboutToQuit.connect(&quit);
    Stdout(app.children[0]).newline;
    +/
    
    /+    
    scope parent = new QObject;
    qtd_qobject(parent.__nativeId);
    Stdout(parent.children[0]).newline;
    +/
    
    
    
    
    //return app.exec();
}

void quit()
{
    Stdout("Quitting").newline;
}
+/

/+
import tango.io.Stdout;

import qt.gui.QMainWindow;

public class TestWindow : QMainWindow
{
    public this()
    {       
        //Stdout(qVersion).newline;
        
        //Stdout(this.children.length).newline;
        auto box = new QDialogButtonBox(this);
        auto closeButton = box.addButton(QDialogButtonBox.Close);
        closeButton.clicked.connect(&onCloseClick);
    }
    
    void onCloseClick()
    {
        Stdout("Close clicked").newline;
    }
}

void main(char[][] args)
{
    scope app = new QApplication(args);
    scope mainWin = new TestWindow;
    mainWin.show();
    return app.exec();
}
+/

/+

import qt.gui.QListWidget;
import qt.gui.QApplication;
import qt.gui.QMainWindow;
import tango.io.Stdout;
void main( char[][] args )
{
    
    Stdout(qVersion).newline;
        static void itemChanged( QListWidgetItem cur, QListWidgetItem prev )
        {
            if(prev )
                {
                    Stdout("Here prev", prev, prev.__nativeId).newline;
                        prev.text; // This causes the SIGSEGV
                    Stdout("There prev").newline;
                }
                
                if( cur )
                {
                    Stdout("Here", cur, cur.__nativeId).newline;
                        cur.text; // This causes the SIGSEGV
                    Stdout("There").newline;
                }
        }
        scope app = new QApplication(args);
        scope mainWin = new QMainWindow;
        scope lw = new QListWidget( mainWin );
        scope lwi = new QListWidgetItem("text", lw);
        lwi.text;
        Stdout("Here 0 ", lwi.__nativeId).newline;
        
        lw.currentItemChanged.connect( &itemChanged );
        mainWin.show;
        return app.exec;
}

+/
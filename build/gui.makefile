## Qt Lib name.
qt_gui_name = QtGui

## Libraries linked to the cpp part (is active only when  CPP_SHARED == true).
gui_link_cpp += qtdcore_cpp $(qt_core_lib_name)

## Libraries linked to the d part (is active only when  CPP_SHARED == true)..
gui_link_d += qtdcore

## Module specific cpp files.
gui_cpp_files += 

## Module specific d files.
gui_d_files += 

## Classes.
## TODO: use list that generated by dgen.
gui_classes = \
    ArrayOps \
	QPushButton \
	QFileIconProvider \
	QPaintDevice \
	QPicture \
	QPixmap \
	QImage \
	QBitmap \
	QStyle \
	QStyleOption \
	QDesktopWidget \
	QMenu \
	QAction \
	QDropEvent \
	QInputContext \
	QWidget \
	QApplication \
	QIcon \
	QIconEngine \
	QPalette \
	QSizePolicy \
	QRegion \
	QFontMetrics \
	QCursor \
	QFont \
	QClipboard \
	QSessionManager \
	QPainterPath  \
	QPainterPath_Element \
	QPaintEvent \
	QTransform \
	QMatrix \
	QPainter \
	QDragLeaveEvent \
	QPolygon \
	QInputEvent \
	QDragEnterEvent \
	QKeyEvent \
	QHideEvent \
	QWheelEvent \
	QMoveEvent \
	QActionGroup \
	QActionEvent \
	QFocusEvent \
	QIconEngineV2 \
	QFontInfo \
	QStyleHintReturn \
	QColor \
	QDragMoveEvent \
	QStyleOptionMenuItem \
	QTabletEvent \
	QShowEvent \
	QResizeEvent \
	QBrush \
	QInputMethodEvent \
	QContextMenuEvent \
	QStyleOptionComplex \
	QMouseEvent \
	QHelpEvent \
	QTextFormat \
	QKeySequence \
	QCloseEvent \
	QGradient \
	QTextItem \
	QTextOption \
	QPolygonF \
	QPen \
	QTextCharFormat \
	QTextListFormat \
	QTextTableFormat \
	QTextLength \
	QTextFrameFormat \
	QTextTableCellFormat \
	QTextBlockFormat \
	QTextImageFormat \
	QFrame \
	QLabel \
	QAbstractButton \
	QMovie \
	QCheckBox \
	QRadioButton \
	QToolButton \
	QStyleOptionButton \
	QStyleOptionToolButton \
	QStyleOptionToolBar \
	QStyleOptionToolBox \
	QStyleOptionToolBoxV2 \
	QStyleOptionSlider \
	QStyleOptionViewItem \
	QStyleOptionHeader \
	QStyleOptionDockWidget \
	QStyleOptionTab \
	QButtonGroup \
	QLCDNumber \
	QAbstractSlider \
	QDial \
	QSlider \
	QScrollBar \
	QPaintEngine \
	QSpacerItem \
	QLayout \
	QLayoutItem \
	QPaintEngineState \
	QBoxLayout \
	QHBoxLayout \
	QVBoxLayout \
	QFormLayout \
	QGridLayout \
	QStackedLayout \
	QAbstractScrollArea \
	QAbstractItemDelegate \
	QAbstractItemView \
	QTreeView \
	QTableView \
	QListView \
	QHeaderView \
	QItemSelection \
	QItemSelectionModel \
	QItemSelectionRange \
	QDirModel \
	QSplitter \
	QSplitterHandle \
	QListWidget \
	QListWidgetItem \
	QMainWindow \
	QMenuBar \
	QToolBar \
	QMessageBox \
	QDockWidget \
	QDialog \
	QStatusBar \
	QTabWidget \
	QTabBar \
	QImageIOHandler \
	QImageReader \
	QTextFrame_iterator \
	QTextBlock_iterator \
	QPrinter \
	QTextLine \
	QTextEdit \
	QTextCursor \
	QTextFrame \
	QTextObject \
	QTextBlock \
	QTextDocument \
	QPrinterInfo \
	QTextList \
	QTextLayout \
	QTextBlockUserData \
	QTextDocumentFragment \
	QTextTable \
	QAbstractTextDocumentLayout \
	QTextBlockGroup \
	QTextObjectInterface \
	QTextInlineObject \
	QAbstractTextDocumentLayout_PaintContext \
	QTextLayout_FormatRange \
	QTextFragment \
	QTextTableCell \
	QPrintEngine \
	QStyleOptionTabWidgetFrame \
	QComboBox \
	QValidator \
	QCompleter \
	QLineEdit \
	QStyleOptionComboBox \
	QStyleOptionFrame \
	QFileDialog \
	QAbstractProxyModel \
	QGraphicsItem \
	QGraphicsItemGroup \
	QGraphicsWidget \
	QGraphicsLayout \
	QGraphicsScene \
	QGraphicsSimpleTextItem \
	QGraphicsRectItem \
	QGraphicsPolygonItem \
	QGraphicsPixmapItem \
	QGraphicsPathItem \
	QGraphicsLineItem \
	QGraphicsEllipseItem \
	QGraphicsLayoutItem \
	QAbstractGraphicsShapeItem \
	QGraphicsTextItem \
	QGraphicsProxyWidget \
	QGraphicsSceneEvent \
	QGraphicsSceneWheelEvent \
	QGraphicsSceneContextMenuEvent \
	QGraphicsSceneMouseEvent \
	QGraphicsSceneResizeEvent \
	QStyleOptionGraphicsItem \
	QGraphicsSceneMoveEvent \
	QGraphicsSceneHoverEvent \
	QGraphicsSceneDragDropEvent \
	QGraphicsSceneHelpEvent \
    QGraphicsView \
    QTableWidgetSelectionRange \
    QStandardItem \
    QUndoStack \
    QTreeWidgetItem \
    QTreeWidget \
    QTextEdit_ExtraSelection \
    QTableWidgetItem \
    QTableWidget \
    QTextOption_Tab \
    QMdiSubWindow \
    QInputMethodEvent_Attribute \
    QMdiArea \
    QUndoCommand \
    QStandardItemModel
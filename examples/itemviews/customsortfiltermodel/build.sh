#! /bin/bash

dmd main.d mysortfilterproxymodel.d window.d -I../../../ -I../../../qt/d1 -L-L../../../lib -L-lqtdgui -L-lqtdcore -L-lQtCore -L-lQtGui -ofmysortfilterproxymodel
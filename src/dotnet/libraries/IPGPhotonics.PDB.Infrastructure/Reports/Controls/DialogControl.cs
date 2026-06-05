using System;
using System.ComponentModel;
using System.Drawing;
using System.Windows.Forms;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;

    internal abstract class DialogControl : DialogComponentBase
        {
        [UsedImplicitly][Field(Order=1000401,Converter=typeof(SqlColorConverter))] public Color BackColor { get; }
        [UsedImplicitly][Field(Order=1000405,Converter=typeof(SqlColorConverter))] public Color ForeColor { get; }
        [UsedImplicitly][Field(Order=1000402)] public String Cursor { get; }
        [UsedImplicitly][Field(Order=1000409)] public String Text { get; }
        [UsedImplicitly][Field(Order=1000410)] public String ClickEvent { get; }
        [UsedImplicitly][Field(Order=1000411)] public String DoubleClickEvent { get; }
        [UsedImplicitly][Field(Order=1000412)] public String EnterEvent { get; }
        [UsedImplicitly][Field(Order=1000404)] public String Font { get; }
        [UsedImplicitly][Field(Order=1000414)] public String KeyDownEvent { get; }
        [UsedImplicitly][Field(Order=1000415)] public String KeyPressEvent { get; }
        [UsedImplicitly][Field(Order=1000416)] public String KeyUpEvent { get; }
        [UsedImplicitly][Field(Order=1000413)] public String LeaveEvent { get; }
        [UsedImplicitly][Field(Order=1000417)] public String MouseDownEvent { get; }
        [UsedImplicitly][Field(Order=1000420)] public String MouseEnterEvent { get; }
        [UsedImplicitly][Field(Order=1000421)] public String MouseLeaveEvent { get; }
        [UsedImplicitly][Field(Order=1000418)] public String MouseMoveEvent { get; }
        [UsedImplicitly][Field(Order=1000419)] public String MouseUpEvent { get; }
        [UsedImplicitly][Field(Order=1000424)] public String PaintEvent { get; }
        [UsedImplicitly][Field(Order=1000422)] public String ResizeEvent { get; }
        [UsedImplicitly][Field(Order=1000423)] public String TextChangedEvent { get; }
        [UsedImplicitly][Field(Order=1000406)] public RightToLeft RightToLeft { get; }
        [UsedImplicitly][Field(Order=1000403)][DefaultValue(true)] public Boolean Enabled { get; } = true;
        [UsedImplicitly][Field(Order=1000408)][DefaultValue(true)] public Boolean TabStop { get; } = true;
        [UsedImplicitly][Field(Order=1000407)][DefaultValue(-1)] public Int32 TabIndex { get; } = -1;
        }
    }

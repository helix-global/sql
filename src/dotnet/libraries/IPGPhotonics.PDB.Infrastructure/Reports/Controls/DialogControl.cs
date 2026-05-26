using System;
using System.ComponentModel;
using System.Windows.Forms;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    using Color=System.Windows.Media.Color;

    public class DialogControl : DialogComponentBase
        {
        [UsedImplicitly][Field(Converter=typeof(SqlColorConverter))] public Color BackColor { get; }
        [UsedImplicitly][Field(Converter=typeof(SqlColorConverter))] public Color ForeColor { get; }
        [UsedImplicitly][Field] public String Text { get; }
        [UsedImplicitly][Field] public String ClickEvent { get; }
        [UsedImplicitly][Field] public String DoubleClickEvent { get; }
        [UsedImplicitly][Field] public String EnterEvent { get; }
        [UsedImplicitly][Field] public String Font { get; }
        [UsedImplicitly][Field] public String KeyDownEvent { get; }
        [UsedImplicitly][Field] public String KeyPressEvent { get; }
        [UsedImplicitly][Field] public String KeyUpEvent { get; }
        [UsedImplicitly][Field] public String LeaveEvent { get; }
        [UsedImplicitly][Field] public String MouseDownEvent { get; }
        [UsedImplicitly][Field] public String MouseEnterEvent { get; }
        [UsedImplicitly][Field] public String MouseLeaveEvent { get; }
        [UsedImplicitly][Field] public String MouseMoveEvent { get; }
        [UsedImplicitly][Field] public String MouseUpEvent { get; }
        [UsedImplicitly][Field] public String PaintEvent { get; }
        [UsedImplicitly][Field] public String ResizeEvent { get; }
        [UsedImplicitly][Field] public String TextChangedEvent { get; }
        [UsedImplicitly][Field] public RightToLeft RightToLeft { get; }
        [UsedImplicitly][Field] public Boolean Enabled { get; } = true;
        [UsedImplicitly][Field] public Boolean TabStop { get; } = true;
        [UsedImplicitly][Field] public Int32 TabIndex { get; }
        }
    }

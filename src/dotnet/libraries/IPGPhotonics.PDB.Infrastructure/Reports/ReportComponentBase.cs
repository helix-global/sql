using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Windows.Media;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;
using IPGPhotonics.PDB.Infrastructure.Reports;

namespace IPGPhotonics.PDB.Infrastructure
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    public abstract class ReportComponentBase : ComponentBase
        {
        [UsedImplicitly][Field("Border.Lines")] public BorderLines BorderLines { get; }
        [UsedImplicitly][Field("Border.Color")][TypeConverter(typeof(SqlColorConverter))] public Color BorderColor { get; }
        [UsedImplicitly][Field][TypeConverter(typeof(SqlColorConverter))] public Color FillColor { get; }
        [UsedImplicitly][Field] public StylePriority EvenStylePriority { get; }
        [UsedImplicitly][Field] public String AfterDataEvent { get; }
        [UsedImplicitly][Field] public String AfterPrintEvent { get; }
        [UsedImplicitly][Field] public String BeforePrintEvent { get; }
        [UsedImplicitly][Field] public String Bookmark { get; }
        [UsedImplicitly][Field] public String ClickEvent { get; }
        [UsedImplicitly][Field] public String EvenStyle { get; }
        [UsedImplicitly][Field] public String HoverStyle { get; }
        [UsedImplicitly][Field] public String MouseDownEvent { get; }
        [UsedImplicitly][Field] public String MouseEnterEvent { get; }
        [UsedImplicitly][Field] public String MouseLeaveEvent { get; }
        [UsedImplicitly][Field] public String MouseMoveEvent { get; }
        [UsedImplicitly][Field] public String MouseUpEvent { get; }
        [UsedImplicitly][Field] public String Style { get; }
        [UsedImplicitly][Field] public String Cursor { get; }
        [UsedImplicitly][Field] public Boolean CanGrow { get; }
        [UsedImplicitly][Field] public Boolean CanShrink { get; }
        [UsedImplicitly][Field] public Boolean Exportable { get; } = true;
        [UsedImplicitly][Field] public Boolean GrowToBottom { get; }
        [UsedImplicitly][Field] public Boolean Printable { get; } = true;
        [UsedImplicitly][Field] public PrintOn PrintOn { get; }
        [UsedImplicitly][Field] public ShiftMode ShiftMode { get; }
        }
    }

using System;
using System.ComponentModel;
using System.Drawing;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class ReportComponentBase : ComponentBase
        {
        [UsedImplicitly][Field(Order=1000314)] public StylePriority EvenStylePriority { get; }
        [UsedImplicitly][Field(Order=1000319)] public String AfterDataEvent { get; }
        [UsedImplicitly][Field(Order=1000318)] public String AfterPrintEvent { get; }
        [UsedImplicitly][Field(Order=1000317)] public String BeforePrintEvent { get; }
        [UsedImplicitly][Field(Order=1000307)] public String Bookmark { get; }
        [UsedImplicitly][Field(Order=1000320)] public String ClickEvent { get; }
        [UsedImplicitly][Field(Order=1000313)] public String EvenStyle { get; }
        [UsedImplicitly][Field(Order=1000315)] public String HoverStyle { get; }
        [UsedImplicitly][Field(Order=1000323)] public String MouseDownEvent { get; }
        [UsedImplicitly][Field(Order=1000324)] public String MouseEnterEvent { get; }
        [UsedImplicitly][Field(Order=1000325)] public String MouseLeaveEvent { get; }
        [UsedImplicitly][Field(Order=1000321)] public String MouseMoveEvent { get; }
        [UsedImplicitly][Field(Order=1000322)] public String MouseUpEvent { get; }
        [UsedImplicitly][Field(Order=1000312)] public virtual String Style { get; }
        [UsedImplicitly][Field(Order=1000305)] public String Cursor { get; }
        [UsedImplicitly][Field(Order=1000308)] public Boolean CanGrow { get; }
        [UsedImplicitly][Field(Order=1000309)] public Boolean CanShrink { get; }
        [UsedImplicitly][Field(Order=1000302)][DefaultValue(true)] public Boolean Exportable { get; } = true;
        [UsedImplicitly][Field(Order=1000310)] public Boolean GrowToBottom { get; }
        [UsedImplicitly][Field(Order=1000301)][DefaultValue(true)] public Boolean Printable { get; } = true;
        [UsedImplicitly][Field(Order=1000316)][DefaultValue(PrintOn.FirstPage|PrintOn.LastPage|PrintOn.OddPages|PrintOn.EvenPages|PrintOn.RepeatedBand|PrintOn.SinglePage)] public PrintOn PrintOn { get; } = PrintOn.FirstPage|PrintOn.LastPage|PrintOn.OddPages|PrintOn.EvenPages|PrintOn.RepeatedBand|PrintOn.SinglePage;
        [UsedImplicitly][Field(Order=1000311)][DefaultValue(ShiftMode.Always)] public ShiftMode ShiftMode { get; } = ShiftMode.Always;
        [UsedImplicitly][Field(Order=1000303)] public Border Border { get; } = new Border();
        [UsedImplicitly][Field(Order=1000304)][DefaultValue(typeof(FastReportSolidFill),"Color=Transparent")] public FillBase Fill { get; } = new FastReportSolidFill(Color.Transparent);
        [UsedImplicitly][Field(Order=1000306)] public FastReportHyperlink Hyperlink { get; } = new FastReportHyperlink();
        }
    }

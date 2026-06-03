using System;
using System.Drawing;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    using FormBorderStyle=System.Windows.Forms.FormBorderStyle;
    using RightToLeft=System.Windows.Forms.RightToLeft;

    [FastReportClass("DialogPage")]
    internal sealed class DialogPage : PageBase
        {
        [UsedImplicitly][Field(Order=1000401)] public String AcceptButton { get; }
        [UsedImplicitly][Field(Order=1000402)] public String CancelButton { get; }
        [UsedImplicitly][Field(Order=1000404)] public String Font { get; }
        [UsedImplicitly][Field(Order=1000409)] public String FormClosedEvent { get; }
        [UsedImplicitly][Field(Order=1000410)] public String FormClosingEvent { get; }
        [UsedImplicitly][Field(Order=1000408)] public String LoadEvent { get; }
        [UsedImplicitly][Field(Order=1000413)] public String PaintEvent { get; }
        [UsedImplicitly][Field(Order=1000412)] public String ResizeEvent { get; }
        [UsedImplicitly][Field(Order=1000411)] public String ShownEvent { get; }
        [UsedImplicitly][Field(Order=1000407)] public String Text { get; }
        [UsedImplicitly][Field(Order=1000403,Converter=typeof(SqlColorConverter))] public Color BackColor { get; }
        [UsedImplicitly][Field(Order=1000405,Converter=typeof(SqlEnumConverter<FormBorderStyle>))] public FormBorderStyle FormBorderStyle { get; }
        [UsedImplicitly][Field(Order=1000406,Converter=typeof(SqlEnumConverter<RightToLeft>))] public RightToLeft RightToLeft { get; }
        }
    }

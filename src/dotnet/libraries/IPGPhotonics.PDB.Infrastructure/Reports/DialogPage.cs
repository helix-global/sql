using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Media;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    using FormBorderStyle=System.Windows.Forms.FormBorderStyle;
    using RightToLeft=System.Windows.Forms.RightToLeft;

    [FastReportClass("DialogPage")]
    internal class DialogPage : PageBase
        {
        [UsedImplicitly][Field] public String AcceptButton { get; }
        [UsedImplicitly][Field] public String CancelButton { get; }
        [UsedImplicitly][Field] public String Font { get; }
        [UsedImplicitly][Field] public String FormClosedEvent { get; }
        [UsedImplicitly][Field] public String FormClosingEvent { get; }
        [UsedImplicitly][Field] public String LoadEvent { get; }
        [UsedImplicitly][Field] public String PaintEvent { get; }
        [UsedImplicitly][Field] public String ResizeEvent { get; }
        [UsedImplicitly][Field] public String ShownEvent { get; }
        [UsedImplicitly][Field] public String Text { get; }
        [UsedImplicitly][Field][TypeConverter(typeof(SqlColorConverter))] public Color BackColor { get; }
        [UsedImplicitly][Field] public FormBorderStyle FormBorderStyle { get; }
        [UsedImplicitly][Field] public RightToLeft RightToLeft { get; }
        }
    }

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class DataFilterBaseControl : DialogControl
        {
        [UsedImplicitly][Field] public Boolean AutoFill { get; } = true;
        [UsedImplicitly][Field] public Boolean AutoFilter { get; } = true;
        [UsedImplicitly][Field] public String DataColumn { get; }
        [UsedImplicitly][Field] public String DataLoadedEvent { get; }
        [UsedImplicitly][Field] public String ReportParameter { get; }
        [UsedImplicitly][Field] public FilterOperation FilterOperation { get; }
        }
    }

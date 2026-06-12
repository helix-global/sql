using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Windows;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class FastReportTextObjectBase : FastReportBreakableComponent
        {
        [UsedImplicitly][Field(Order=1000501)] public String Text { get; }
        [UsedImplicitly][Field(Order=1000504)] public String Brackets { get; }
        [UsedImplicitly][Field(Order=1000506)] public String HideValue { get; }
        [UsedImplicitly][Field(Order=1000507)] public String NullValue { get; }
        [UsedImplicitly][Field(Order=1000502,Converter=typeof(FastReportThicknessConverter))][DefaultValue("2,0,2,0")] public virtual Thickness Padding { get; } = new Thickness(2,0,2,0);
        [UsedImplicitly][Field(Order=1000503)][DefaultValue(true)] public Boolean AllowExpressions { get; } = true;
        [UsedImplicitly][Field(Order=1000505)] public Boolean HideZeros { get; }
        [UsedImplicitly][Field(Order=1000509)] public Duplicates Duplicates { get; }
        [UsedImplicitly][Field(Order=1000508)] public ProcessAt ProcessAt { get; }
        [UsedImplicitly][Field(Order=1000510,EmptyIfNull = true)] public IList<FastReportFormatBase> Formats { get; } = new List<FastReportFormatBase>{ new FastReportGeneralFormat() };
        [UsedImplicitly][Field(Order = 1000511)][DefaultValue("General")] public FastReportFormatBase Format
            {
            get { return Formats.FirstOrDefault(); }
            internal set
                {
                if (value == null) { value = new FastReportGeneralFormat(); }
                if (Formats.Count == 0)
                    {
                    Formats.Add(value);
                    }
                else
                    {
                    Formats[0] = value;
                    }
                }
            }
        }
    }

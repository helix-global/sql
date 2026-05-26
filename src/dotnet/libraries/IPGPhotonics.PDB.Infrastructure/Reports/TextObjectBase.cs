using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Windows;
using BinaryStudio.SqlServer.Infrastructure;
using IPGPhotonics.PDB.Infrastructure.Reports;
using IPGPhotonics.PDB.Infrastructure.Reports.Formats;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    public abstract class TextObjectBase : BreakableComponent
        {
        [UsedImplicitly][Field] public String Text { get; }
        [UsedImplicitly][Field] public String Brackets { get; }
        [UsedImplicitly][Field] public String HideValue { get; }
        [UsedImplicitly][Field] public String NullValue { get; }
        [UsedImplicitly][Field][TypeConverter(typeof(SqlThicknessConverter))] public Thickness Padding { get; }
        [UsedImplicitly][Field] public Boolean AllowExpressions { get; } = true;
        [UsedImplicitly][Field] public Boolean HideZeros { get; }
        [UsedImplicitly][Field] public Duplicates Duplicates { get; }
        [UsedImplicitly][Field] public ProcessAt ProcessAt { get; }
        [UsedImplicitly][Field(EmptyIfNull = true)] public IList<FormatBase> Formats { get; }
        }
    }

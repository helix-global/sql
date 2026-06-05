using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Windows;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class TextObjectBase : BreakableComponent
        {
        [UsedImplicitly][Field(Order=1000501)] public String Text { get; }
        [UsedImplicitly][Field(Order=1000504)] public String Brackets { get; }
        [UsedImplicitly][Field(Order=1000506)] public String HideValue { get; }
        [UsedImplicitly][Field(Order=1000507)] public String NullValue { get; }
        [UsedImplicitly][Field(Order=1000502,Converter=typeof(SqlThicknessConverter))] public Thickness Padding { get; }
        [UsedImplicitly][Field(Order=1000503)][DefaultValue(true)] public Boolean AllowExpressions { get; } = true;
        [UsedImplicitly][Field(Order=1000505)] public Boolean HideZeros { get; }
        [UsedImplicitly][Field(Order=1000509)] public Duplicates Duplicates { get; }
        [UsedImplicitly][Field(Order=1000508)] public ProcessAt ProcessAt { get; }
        [UsedImplicitly][Field(Order=1000510,EmptyIfNull = true)] public IList<FormatBase> Formats { get; }
        [UsedImplicitly][Field(Order=1000511)][DefaultValue("General")] public FormatBase Format { get; } = new GeneralFormat();
        }
    }

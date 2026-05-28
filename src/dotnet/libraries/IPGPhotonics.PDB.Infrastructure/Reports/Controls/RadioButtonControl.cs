using System;
using System.Drawing;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("RadioButtonControl")]
    internal sealed class RadioButtonControl : ButtonBaseControl
        {
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<ContentAlignment>))] public ContentAlignment CheckAlign { get; }
        [UsedImplicitly][Field] public Boolean Checked { get; }
        [UsedImplicitly][Field] public String CheckedChangedEvent { get; }
        }
    }
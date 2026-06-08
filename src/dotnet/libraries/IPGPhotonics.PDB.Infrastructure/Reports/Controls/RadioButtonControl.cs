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
        [UsedImplicitly][Field(Order=1000701,Converter=typeof(SqlEnumConverter<ContentAlignment>))] public ContentAlignment CheckAlign { get; }
        [UsedImplicitly][Field(Order=1000702)] public Boolean Checked { get; }
        [UsedImplicitly][Field(Order=1000703)] public String CheckedChangedEvent { get; }
        }
    }
using System.Windows.Forms;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("ButtonControl")]
    internal sealed class FastReportButtonControl : FastReportButtonBaseControl
        {
        [UsedImplicitly][Field(Order=1000700,Converter=typeof(SqlEnumConverter<DialogResult>))] public DialogResult DialogResult { get; }
        }
    }
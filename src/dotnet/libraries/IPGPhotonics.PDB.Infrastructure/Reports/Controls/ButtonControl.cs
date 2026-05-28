using System.ComponentModel;
using System.Windows.Forms;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("ButtonControl")]
    internal sealed class ButtonControl : ButtonBaseControl
        {
        [UsedImplicitly][Field(Converter=typeof(SqlEnumConverter<DialogResult>))] public DialogResult DialogResult { get; }
        }
    }
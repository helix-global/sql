using System.Windows.Forms;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("PanelControl")]
    internal sealed class PanelControl : ParentControl
        {
        [UsedImplicitly][Field(Order=1000601,Converter=typeof(SqlEnumConverter<BorderStyle>))] public BorderStyle BorderStyle { get; }
        }
    }
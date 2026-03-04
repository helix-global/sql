using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptTemporalPeriodDefinition : SqlScriptCodeObject<SqlTemporalPeriodDefinition>
        {
        public String Name { get { return Source.Name; }}
        public TemporalPeriodType Type { get { return Source.Type; }}

        #region ctor{IServiceProvider,SqlTemporalPeriodDefinition}
        public SqlScriptTemporalPeriodDefinition(IServiceProvider context,SqlTemporalPeriodDefinition source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
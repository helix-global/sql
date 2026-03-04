using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptTargetTableExpression : SqlScriptCodeObject<SqlTargetTableExpression>
        {
        public String OpenDataSourceCommandString { get { return Source.OpenDataSourceCommandString; }}

        #region ctor{IServiceProvider,SqlTargetTableExpression}
        public SqlScriptTargetTableExpression(IServiceProvider context,SqlTargetTableExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlTableVariableRefExpression))]
    internal sealed class SqlScriptTableVariableRefExpression : SqlScriptTableExpression<SqlTableVariableRefExpression>
        {
        #region ctor{IServiceProvider,SqlTableVariableRefExpression}
        public SqlScriptTableVariableRefExpression(IServiceProvider context,SqlTableVariableRefExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
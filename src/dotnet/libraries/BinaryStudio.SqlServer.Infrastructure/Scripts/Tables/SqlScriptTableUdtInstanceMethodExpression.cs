using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlTableUdtInstanceMethodExpression))]
    internal sealed class SqlScriptTableUdtInstanceMethodExpression : SqlScriptTableUdtInstanceMemberExpression<SqlTableUdtInstanceMethodExpression>
        {
        #region ctor{IServiceProvider,SqlTableUdtInstanceMethodExpression}
        public SqlScriptTableUdtInstanceMethodExpression(IServiceProvider context,SqlTableUdtInstanceMethodExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
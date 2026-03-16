using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlUdtStaticMethodExpression))]
    internal sealed class SqlScriptUdtStaticMethodExpression : SqlScriptUdtStaticMemberExpression<SqlUdtStaticMethodExpression>
        {
        #region ctor{IServiceProvider,SqlUdtStaticMethodExpression}
        public SqlScriptUdtStaticMethodExpression(IServiceProvider context,SqlUdtStaticMethodExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
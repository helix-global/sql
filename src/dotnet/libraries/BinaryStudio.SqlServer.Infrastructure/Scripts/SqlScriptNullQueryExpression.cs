using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlNullQueryExpression))]
    internal sealed class SqlScriptNullQueryExpression : SqlScriptQueryExpression<SqlNullQueryExpression>
        {
        #region ctor{IServiceProvider,SqlNullQueryExpression}
        public SqlScriptNullQueryExpression(IServiceProvider context,SqlNullQueryExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
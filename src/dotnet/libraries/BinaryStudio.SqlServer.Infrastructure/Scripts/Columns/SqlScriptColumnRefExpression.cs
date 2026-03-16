using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlColumnRefExpression))]
    internal sealed class SqlScriptColumnRefExpression : SqlScriptScalarRefExpression<SqlColumnRefExpression>
        {
        #region ctor{IServiceProvider,SqlColumnRefExpression}
        public SqlScriptColumnRefExpression(IServiceProvider context,SqlColumnRefExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
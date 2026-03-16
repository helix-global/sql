using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlNullScalarExpression))]
    internal sealed class SqlScriptNullScalarExpression : SqlScriptScalarExpression<SqlNullScalarExpression>
        {
        #region ctor{IServiceProvider,SqlNullScalarExpression}
        public SqlScriptNullScalarExpression(IServiceProvider context,SqlNullScalarExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
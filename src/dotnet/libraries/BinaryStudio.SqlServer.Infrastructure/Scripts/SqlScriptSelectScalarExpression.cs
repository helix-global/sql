using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlSelectScalarExpression))]
    internal sealed class SqlScriptSelectScalarExpression : SqlScriptSelectExpression<SqlSelectScalarExpression>
        {
        #region ctor{IServiceProvider,SqlSelectScalarExpression}
        public SqlScriptSelectScalarExpression(IServiceProvider context,SqlSelectScalarExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
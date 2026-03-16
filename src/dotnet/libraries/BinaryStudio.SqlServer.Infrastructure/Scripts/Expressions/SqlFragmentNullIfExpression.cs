using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(NullIfExpression))]
    internal sealed class SqlFragmentNullIfExpression : SqlFragmentPrimaryExpression<NullIfExpression>
        {
        #region ctor{IServiceProvider,NullIfExpression}
        public SqlFragmentNullIfExpression(IServiceProvider context,NullIfExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlFragmentScalarExpression<T> : SqlFragmentObject<T>,ISqlScriptScalarExpression
        where T: ScalarExpression
        {
        #region ctor{IServiceProvider,T}
        protected SqlFragmentScalarExpression(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
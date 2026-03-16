using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(UserDefinedTypePropertyAccess))]
    internal sealed class SqlFragmentUserDefinedTypePropertyAccess : SqlFragmentPrimaryExpression<UserDefinedTypePropertyAccess>
        {
        #region ctor{IServiceProvider,UserDefinedTypePropertyAccess}
        public SqlFragmentUserDefinedTypePropertyAccess(IServiceProvider context,UserDefinedTypePropertyAccess source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
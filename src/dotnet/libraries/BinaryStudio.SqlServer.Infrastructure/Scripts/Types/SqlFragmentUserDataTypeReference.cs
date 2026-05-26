using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(UserDataTypeReference))]
    internal sealed class SqlFragmentUserDataTypeReference : SqlFragmentParameterizedDataTypeReference<UserDataTypeReference>
        {
        #region ctor{IServiceProvider,UserDataTypeReference}
        public SqlFragmentUserDataTypeReference(IServiceProvider context,UserDataTypeReference source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
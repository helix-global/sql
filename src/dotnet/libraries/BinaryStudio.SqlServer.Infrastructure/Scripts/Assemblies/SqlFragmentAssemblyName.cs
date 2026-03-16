using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    /// <summary>
    /// Represents CLR assembly names.
    /// </summary>
    [SqlScriptObject(typeof(AssemblyName))]
    internal sealed class SqlFragmentAssemblyName : SqlFragmentObject<AssemblyName>
        {
        #region P:ClassName:SqlIdentifier
        /// <summary>
        /// The class name, optional can be <see langword="null"/>.
        /// </summary>
        [UsedImplicitly][Field] public SqlIdentifier ClassName { get; }
        #endregion
        #region P:Name:SqlIdentifier
        /// <summary>
        /// The name of the assembly.
        /// </summary>
        [UsedImplicitly][Field] public SqlIdentifier Name { get; }
        #endregion

        #region ctor{IServiceProvider,AssemblyName}
        public SqlFragmentAssemblyName(IServiceProvider context,AssemblyName source)
            : base(context,source)
            {
            }
        #endregion

        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return $"[{ClassName}].[{Name}]";
            }
        #endregion
        }
    }